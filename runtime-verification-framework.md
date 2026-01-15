# Runtime Verification Framework

## Overview

This framework provides **general-purpose runtime verification** for any migration challenge, regardless of technology stack.

## Core Concept

Each challenge defines a **Runtime Spec** that describes:
1. How to start the application
2. How to verify it's running correctly
3. What behaviors to test
4. Performance expectations

## Architecture

```
┌─────────────────────────────────────────────────┐
│           Runtime Orchestrator                  │
│  (Reads spec, manages lifecycle, reports)       │
└───────────────┬─────────────────────────────────┘
                │
                │ Uses
                ▼
┌─────────────────────────────────────────────────┐
│         Challenge Runtime Spec                  │
│   (YAML/JSON config per challenge)              │
└───────────────┬─────────────────────────────────┘
                │
                │ Defines
                ▼
┌─────────────────────────────────────────────────┐
│         Adapter Interface                       │
│   (CLI, WebApp, API, Desktop App)               │
└─────────────────────────────────────────────────┘
```

## Adapter Types

### 1. CLI Adapter (Python, Perl scripts)
```yaml
adapter: cli
lifecycle:
  setup: "pip install -e ."
  verify: "which log_analyzer"

tests:
  - name: "analyze_sample_log"
    command: "log_analyzer --input test.log --stats"
    expect_exit_code: 0
    expect_stdout_json: "golden-outputs/stats.json"
    timeout: 5

  - name: "handles_empty_file"
    command: "log_analyzer --input empty.log --stats"
    expect_exit_code: 0
    expect_stderr_contains: ""
```

### 2. WebApp Adapter (Angular, React)
```yaml
adapter: webapp
lifecycle:
  setup: "npm install"
  start: "npm start"
  health: "curl http://localhost:4200/health || curl http://localhost:4200/"
  stop: "kill ${PID}"

endpoint:
  url: "http://localhost:4200"
  ready_pattern: "Compiled successfully|webpack compiled"
  startup_timeout: 60

tests:
  - name: "homepage_loads"
    type: "http"
    method: "GET"
    path: "/"
    expect_status: 200
    expect_body_contains: ["<app-root>", "Employee Directory"]

  - name: "loads_test_data"
    type: "http"
    method: "GET"
    path: "/api/employees"
    expect_status: 200
    expect_json_length: 20
    expect_json_schema:
      type: "array"
      items:
        properties:
          id: {type: "integer"}
          name: {type: "string"}
```

### 3. API Adapter (Spring Boot, Express)
```yaml
adapter: api
lifecycle:
  setup: "mvn clean install -DskipTests"
  start: "mvn spring-boot:run"
  health: "curl http://localhost:8080/actuator/health"
  stop: "kill ${PID}"

endpoint:
  url: "http://localhost:8080"
  ready_pattern: "Started.*Application in"
  startup_timeout: 90

tests:
  - name: "list_products"
    type: "http"
    method: "GET"
    path: "/api/products"
    expect_status: 200
    expect_json_file: "golden-outputs/list-all.json"

  - name: "get_product_by_id"
    type: "http"
    method: "GET"
    path: "/api/products/1"
    expect_status: 200
    expect_json_subset:
      id: 1
      name: "Laptop"

  - name: "search_products"
    type: "http"
    method: "GET"
    path: "/api/products/search?q=widget"
    expect_status: 200
    expect_json_file: "golden-outputs/search-widget.json"

  - name: "404_for_missing_product"
    type: "http"
    method: "GET"
    path: "/api/products/999"
    expect_status: 404
```

## Performance Benchmarks

```yaml
performance:
  startup_time:
    max_seconds: 30
    measured_from: "start command"
    measured_until: "ready_pattern match"

  response_time:
    endpoints:
      - path: "/api/products"
        max_ms: 200
        percentile: 95
        samples: 100

  memory:
    max_mb: 512
    measured_at: "after warmup"
    warmup_requests: 50

  throughput:
    endpoint: "/api/products"
    min_rps: 100
    duration_seconds: 10
```

## Implementation

### Core Orchestrator Script

```bash
#!/bin/bash
# runtime-verifier.sh

CHALLENGE_DIR=$1
OUTPUT_DIR=$2
RUNTIME_SPEC="$CHALLENGE_DIR/runtime-spec.yaml"

if [[ ! -f "$RUNTIME_SPEC" ]]; then
    echo "No runtime-spec.yaml found, skipping runtime verification"
    exit 0
fi

# Parse spec and run verification
python3 scripts/runtime-orchestrator.py \
    --spec "$RUNTIME_SPEC" \
    --output "$OUTPUT_DIR" \
    --report runtime-results.json
```

### Python Orchestrator

```python
#!/usr/bin/env python3
# scripts/runtime-orchestrator.py

import yaml
import subprocess
import time
import requests
import json
from pathlib import Path

class RuntimeVerifier:
    def __init__(self, spec_file, output_dir):
        with open(spec_file) as f:
            self.spec = yaml.safe_load(f)
        self.output_dir = Path(output_dir)
        self.process = None
        self.results = {
            "tests": [],
            "performance": {},
            "passed": 0,
            "failed": 0
        }

    def run(self):
        try:
            adapter = self.get_adapter()
            adapter.setup()
            adapter.start()
            adapter.wait_for_ready()
            adapter.run_tests()
            adapter.measure_performance()
            return self.results
        finally:
            adapter.cleanup()

    def get_adapter(self):
        adapter_type = self.spec['adapter']
        if adapter_type == 'cli':
            return CLIAdapter(self.spec, self.output_dir, self.results)
        elif adapter_type == 'webapp':
            return WebAppAdapter(self.spec, self.output_dir, self.results)
        elif adapter_type == 'api':
            return APIAdapter(self.spec, self.output_dir, self.results)
        else:
            raise ValueError(f"Unknown adapter: {adapter_type}")

class BaseAdapter:
    def __init__(self, spec, output_dir, results):
        self.spec = spec
        self.output_dir = output_dir
        self.results = results
        self.process = None

    def setup(self):
        """Run setup commands"""
        cmd = self.spec['lifecycle']['setup']
        subprocess.run(cmd, shell=True, cwd=self.output_dir, check=True)

    def cleanup(self):
        """Kill process and clean up"""
        if self.process:
            self.process.terminate()
            self.process.wait(timeout=5)

class CLIAdapter(BaseAdapter):
    def start(self):
        pass  # CLI tools don't need to "start"

    def wait_for_ready(self):
        # Verify the CLI tool exists
        verify_cmd = self.spec['lifecycle'].get('verify', 'true')
        subprocess.run(verify_cmd, shell=True, check=True)

    def run_tests(self):
        for test in self.spec['tests']:
            result = self.run_cli_test(test)
            self.results['tests'].append(result)
            if result['passed']:
                self.results['passed'] += 1
            else:
                self.results['failed'] += 1

    def run_cli_test(self, test):
        result = {
            "name": test['name'],
            "passed": False,
            "error": None
        }

        try:
            proc = subprocess.run(
                test['command'],
                shell=True,
                cwd=self.output_dir,
                capture_output=True,
                text=True,
                timeout=test.get('timeout', 30)
            )

            # Check exit code
            expected_code = test.get('expect_exit_code', 0)
            if proc.returncode != expected_code:
                result['error'] = f"Exit code {proc.returncode}, expected {expected_code}"
                return result

            # Check stdout against golden file
            if 'expect_stdout_json' in test:
                golden_file = Path(test['expect_stdout_json'])
                with open(golden_file) as f:
                    expected = json.load(f)
                actual = json.loads(proc.stdout)
                if actual != expected:
                    result['error'] = "Output doesn't match golden file"
                    return result

            result['passed'] = True

        except subprocess.TimeoutExpired:
            result['error'] = f"Timeout after {test.get('timeout', 30)}s"
        except Exception as e:
            result['error'] = str(e)

        return result

    def measure_performance(self):
        # Performance benchmarks for CLI tools
        pass

class WebAppAdapter(BaseAdapter):
    def start(self):
        """Start the web server"""
        start_cmd = self.spec['lifecycle']['start']
        self.process = subprocess.Popen(
            start_cmd,
            shell=True,
            cwd=self.output_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )

    def wait_for_ready(self):
        """Wait for server to be ready"""
        import re
        ready_pattern = self.spec['endpoint']['ready_pattern']
        timeout = self.spec['endpoint'].get('startup_timeout', 60)
        start_time = time.time()

        while time.time() - start_time < timeout:
            line = self.process.stdout.readline()
            if re.search(ready_pattern, line):
                print(f"✓ App ready: {line.strip()}")
                return
            time.sleep(0.1)

        raise TimeoutError(f"App didn't start within {timeout}s")

    def run_tests(self):
        base_url = self.spec['endpoint']['url']

        for test in self.spec['tests']:
            result = self.run_http_test(base_url, test)
            self.results['tests'].append(result)
            if result['passed']:
                self.results['passed'] += 1
            else:
                self.results['failed'] += 1

    def run_http_test(self, base_url, test):
        result = {
            "name": test['name'],
            "passed": False,
            "error": None
        }

        try:
            url = base_url + test['path']
            method = test.get('method', 'GET')

            response = requests.request(method, url, timeout=test.get('timeout', 10))

            # Check status code
            expected_status = test.get('expect_status', 200)
            if response.status_code != expected_status:
                result['error'] = f"Status {response.status_code}, expected {expected_status}"
                return result

            # Check body contains strings
            if 'expect_body_contains' in test:
                for substring in test['expect_body_contains']:
                    if substring not in response.text:
                        result['error'] = f"Body doesn't contain: {substring}"
                        return result

            # Check JSON matches golden file
            if 'expect_json_file' in test:
                golden_file = Path(test['expect_json_file'])
                with open(golden_file) as f:
                    expected = json.load(f)
                actual = response.json()
                if actual != expected:
                    result['error'] = "JSON doesn't match golden file"
                    return result

            result['passed'] = True

        except Exception as e:
            result['error'] = str(e)

        return result

    def measure_performance(self):
        if 'performance' not in self.spec:
            return

        perf = self.spec['performance']

        # Measure response times
        if 'response_time' in perf:
            self.measure_response_times(perf['response_time'])

    def measure_response_times(self, config):
        import statistics

        base_url = self.spec['endpoint']['url']

        for endpoint_config in config['endpoints']:
            path = endpoint_config['path']
            samples = endpoint_config.get('samples', 100)
            max_ms = endpoint_config['max_ms']

            times = []
            for _ in range(samples):
                start = time.time()
                requests.get(base_url + path)
                elapsed = (time.time() - start) * 1000
                times.append(elapsed)

            p95 = statistics.quantiles(times, n=20)[18]  # 95th percentile

            self.results['performance'][path] = {
                "p95_ms": p95,
                "max_allowed_ms": max_ms,
                "passed": p95 <= max_ms
            }

class APIAdapter(WebAppAdapter):
    """API adapter is similar to WebApp, just different defaults"""
    pass

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--spec', required=True)
    parser.add_argument('--output', required=True)
    parser.add_argument('--report', required=True)
    args = parser.parse_args()

    verifier = RuntimeVerifier(args.spec, args.output)
    results = verifier.run()

    with open(args.report, 'w') as f:
        json.dump(results, f, indent=2)

    print(f"\n{'='*50}")
    print(f"Runtime Verification Results")
    print(f"{'='*50}")
    print(f"Passed: {results['passed']}")
    print(f"Failed: {results['failed']}")

    for test in results['tests']:
        status = "✓" if test['passed'] else "✗"
        print(f"{status} {test['name']}")
        if test['error']:
            print(f"  Error: {test['error']}")

    if results['performance']:
        print(f"\nPerformance:")
        for path, metrics in results['performance'].items():
            status = "✓" if metrics['passed'] else "✗"
            print(f"{status} {path}: {metrics['p95_ms']:.2f}ms (max: {metrics['max_allowed_ms']}ms)")

    exit(0 if results['failed'] == 0 else 1)
```

## Example Runtime Specs

### Challenge 1: Angular
```yaml
# challenges/1-angularjs-to-angular/runtime-spec.yaml
adapter: webapp

lifecycle:
  setup: "npm install"
  start: "npm start"
  health: "curl -f http://localhost:4200/ || exit 1"
  stop: "kill ${PID}"

endpoint:
  url: "http://localhost:4200"
  ready_pattern: "Compiled successfully"
  startup_timeout: 60

tests:
  - name: "homepage_loads"
    type: "http"
    method: "GET"
    path: "/"
    expect_status: 200
    expect_body_contains: ["<app-root>", "Employee Directory"]

  - name: "loads_employees"
    type: "http"
    method: "GET"
    path: "/assets/test-inputs/employees.json"
    expect_status: 200
    expect_json_length: 20

performance:
  startup_time:
    max_seconds: 30

  response_time:
    endpoints:
      - path: "/"
        max_ms: 500
        samples: 20
```

### Challenge 2: Python
```yaml
# challenges/2-perl-to-python/runtime-spec.yaml
adapter: cli

lifecycle:
  setup: "pip install -e ."
  verify: "which log_analyzer || test -f log_analyzer.py"

tests:
  - name: "stats_output"
    command: "python log_analyzer.py ../test-inputs/sample.log --stats"
    expect_exit_code: 0
    expect_stdout_json: "../expected-outputs/stats.json"
    timeout: 5

  - name: "errors_json"
    command: "python log_analyzer.py ../test-inputs/sample.log --errors --json"
    expect_exit_code: 0
    expect_stdout_json: "../expected-outputs/errors.json"

  - name: "handles_empty"
    command: "python log_analyzer.py ../test-inputs/empty.log --stats"
    expect_exit_code: 0

performance:
  execution_time:
    command: "python log_analyzer.py ../test-inputs/large.log --stats"
    max_seconds: 2
    iterations: 10
```

### Challenge 3: Spring Boot
```yaml
# challenges/3-struts-to-spring/runtime-spec.yaml
adapter: api

lifecycle:
  setup: "mvn clean install -DskipTests"
  start: "mvn spring-boot:run"
  health: "curl -f http://localhost:8080/actuator/health"
  stop: "kill ${PID}"

endpoint:
  url: "http://localhost:8080"
  ready_pattern: "Started.*Application in"
  startup_timeout: 90

tests:
  - name: "list_all_products"
    method: "GET"
    path: "/api/products"
    expect_status: 200
    expect_json_file: "../expected-outputs/list-all.json"

  - name: "get_product_1"
    method: "GET"
    path: "/api/products/1"
    expect_status: 200
    expect_json_file: "../expected-outputs/get-product-1.json"

  - name: "search_widget"
    method: "GET"
    path: "/api/products/search?q=widget"
    expect_status: 200
    expect_json_file: "../expected-outputs/search-widget.json"

  - name: "filter_electronics"
    method: "GET"
    path: "/api/products/filter?category=Electronics"
    expect_status: 200
    expect_json_file: "../expected-outputs/filter-electronics.json"

  - name: "product_not_found"
    method: "GET"
    path: "/api/products/999"
    expect_status: 404

performance:
  startup_time:
    max_seconds: 45

  response_time:
    endpoints:
      - path: "/api/products"
        max_ms: 200
        samples: 100
      - path: "/api/products/1"
        max_ms: 50
        samples: 100
```

## Integration with Existing Verification

```bash
#!/bin/bash
# challenges/1-angularjs-to-angular/tests/verify-angular-migration.sh

# ... existing static checks ...

# Add at the end:
echo ""
echo "=== PHASE 5: Runtime Verification ==="
echo ""

# Run runtime verifier
cd ../..
./scripts/runtime-verifier.sh \
    challenges/1-angularjs-to-angular \
    "$OUTPUT_DIR" \
    || ERRORS=$((ERRORS + 1))
```

## Benefits

1. **Technology Agnostic**: Same framework for Angular, Python, Spring, anything
2. **Declarative**: Challenge authors write YAML, not bash scripts
3. **Extensible**: Easy to add new adapter types
4. **Comprehensive**: Tests functionality AND performance
5. **Debuggable**: Clear error messages, JSON reports

## What This Catches That Static Analysis Doesn't

- App crashes at runtime
- HTTP endpoints returning wrong status codes
- JSON responses with wrong structure
- Slow startup times
- Memory leaks
- Missing error handling (timeout tests)
- Integration issues (DB connections, external APIs)

This is the "general way" - define the contract, implement adapters for different app types, let the orchestrator handle the rest!
