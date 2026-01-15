#!/usr/bin/env python3
"""
Runtime Verification Orchestrator
Executes runtime tests defined in runtime-spec.yaml
"""

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML is required. Install with: pip install pyyaml")
    sys.exit(1)

try:
    import requests
except ImportError:
    print("WARNING: requests library not found. HTTP tests will be skipped.")
    print("  Install with: pip install requests")
    requests = None


class RuntimeVerifier:
    """Main orchestrator for runtime verification"""

    def __init__(self, spec_file: Path, output_dir: Path, challenge_dir: Path):
        self.spec_file = spec_file
        self.output_dir = output_dir
        self.challenge_dir = challenge_dir

        with open(spec_file) as f:
            self.spec = yaml.safe_load(f)

        self.process = None
        self.results = {
            "challenge": str(challenge_dir),
            "adapter_type": self.spec.get("adapter"),
            "tests": [],
            "performance": {},
            "passed": 0,
            "failed": 0,
            "skipped": 0,
        }

    def run(self) -> Dict[str, Any]:
        """Execute all verification steps"""
        print(f"Adapter type: {self.spec['adapter']}")
        print("")

        adapter = self.get_adapter()

        try:
            print("=== Setup ===")
            adapter.setup()
            print("✓ Setup complete\n")

            if hasattr(adapter, "start"):
                print("=== Starting Application ===")
                adapter.start()
                print("✓ Application started\n")

                print("=== Waiting for Ready ===")
                adapter.wait_for_ready()
                print("✓ Application ready\n")

            print("=== Running Tests ===")
            adapter.run_tests()

            if "performance" in self.spec:
                print("\n=== Performance Benchmarks ===")
                adapter.measure_performance()

            return self.results

        except Exception as e:
            print(f"\n✗ ERROR: {e}")
            self.results["error"] = str(e)
            return self.results

        finally:
            if hasattr(adapter, "cleanup"):
                print("\n=== Cleanup ===")
                adapter.cleanup()

    def get_adapter(self):
        """Get the appropriate adapter for this challenge"""
        adapter_type = self.spec["adapter"]

        if adapter_type == "cli":
            return CLIAdapter(self.spec, self.output_dir, self.challenge_dir, self.results)
        elif adapter_type == "webapp":
            return WebAppAdapter(self.spec, self.output_dir, self.challenge_dir, self.results)
        elif adapter_type == "api":
            return APIAdapter(self.spec, self.output_dir, self.challenge_dir, self.results)
        else:
            raise ValueError(f"Unknown adapter type: {adapter_type}")


class BaseAdapter:
    """Base class for all adapters"""

    def __init__(
        self, spec: Dict, output_dir: Path, challenge_dir: Path, results: Dict
    ):
        self.spec = spec
        self.output_dir = output_dir
        self.challenge_dir = challenge_dir
        self.results = results
        self.process = None

    def setup(self):
        """Run setup commands"""
        setup_cmd = self.spec["lifecycle"]["setup"]
        self._run_command(setup_cmd, "Setup")

    def cleanup(self):
        """Clean up resources"""
        if self.process:
            print("Stopping application...")
            self.process.terminate()
            try:
                self.process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait()

        if "cleanup" in self.spec["lifecycle"]:
            cleanup_cmd = self.spec["lifecycle"]["cleanup"]
            try:
                self._run_command(cleanup_cmd, "Cleanup")
            except:
                pass  # Cleanup failures are non-fatal

    def _run_command(self, cmd: str, label: str) -> subprocess.CompletedProcess:
        """Run a shell command"""
        return subprocess.run(
            cmd, shell=True, cwd=self.output_dir, check=True, capture_output=True, text=True
        )


class CLIAdapter(BaseAdapter):
    """Adapter for command-line tools"""

    def start(self):
        pass  # CLI tools don't need to "start"

    def wait_for_ready(self):
        """Verify the CLI tool is ready"""
        if "verify" in self.spec["lifecycle"]:
            verify_cmd = self.spec["lifecycle"]["verify"]
            self._run_command(verify_cmd, "Verify")

    def run_tests(self):
        """Run all CLI tests"""
        for test in self.spec.get("tests", []):
            result = self._run_cli_test(test)
            self.results["tests"].append(result)

            if result["passed"]:
                self.results["passed"] += 1
                print(f"  ✓ {result['name']}")
            elif result.get("skipped"):
                self.results["skipped"] += 1
                print(f"  ⊘ {result['name']} (skipped)")
            else:
                self.results["failed"] += 1
                print(f"  ✗ {result['name']}")
                if result.get("error"):
                    print(f"    {result['error']}")

    def _run_cli_test(self, test: Dict) -> Dict:
        """Execute a single CLI test"""
        result = {
            "name": test["name"],
            "passed": False,
            "skipped": False,
            "error": None,
        }

        try:
            proc = subprocess.run(
                test["command"],
                shell=True,
                cwd=self.output_dir,
                capture_output=True,
                text=True,
                timeout=test.get("timeout", 30),
            )

            # Check exit code
            expected_code = test.get("expect_exit_code", 0)
            if proc.returncode != expected_code:
                result["error"] = f"Exit code {proc.returncode}, expected {expected_code}"
                return result

            # Check stdout contains expected strings
            if "expect_stdout_contains" in test:
                for substring in test["expect_stdout_contains"]:
                    if substring not in proc.stdout:
                        result["error"] = f"Output missing: '{substring}'"
                        return result

            # Check stdout matches golden JSON file
            if "expect_stdout_json_matches" in test:
                golden_path = self.challenge_dir / test["expect_stdout_json_matches"]
                if not golden_path.exists():
                    result["error"] = f"Golden file not found: {golden_path}"
                    return result

                with open(golden_path) as f:
                    expected = json.load(f)

                try:
                    actual = json.loads(proc.stdout)
                    if actual != expected:
                        result["error"] = "JSON output doesn't match golden file"
                        return result
                except json.JSONDecodeError as e:
                    result["error"] = f"Invalid JSON output: {e}"
                    return result

            result["passed"] = True

        except subprocess.TimeoutExpired:
            result["error"] = f"Timeout after {test.get('timeout', 30)}s"
        except Exception as e:
            result["error"] = str(e)

        return result

    def measure_performance(self):
        """Measure CLI performance"""
        if "performance" not in self.spec:
            return

        # TODO: Implement performance benchmarking
        print("  (Performance benchmarking not yet implemented for CLI)")


class WebAppAdapter(BaseAdapter):
    """Adapter for web applications"""

    def start(self):
        """Start the web server"""
        start_cmd = self.spec["lifecycle"]["start"]
        print(f"  Running: {start_cmd}")

        self.process = subprocess.Popen(
            start_cmd,
            shell=True,
            cwd=self.output_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

    def wait_for_ready(self):
        """Wait for the application to be ready"""
        import re

        ready_pattern = self.spec["endpoint"]["ready_pattern"]
        timeout = self.spec["endpoint"].get("startup_timeout", 60)
        start_time = time.time()

        print(f"  Waiting for pattern: {ready_pattern}")
        print(f"  Timeout: {timeout}s")

        while time.time() - start_time < timeout:
            # Check if process died
            if self.process.poll() is not None:
                raise RuntimeError("Application process died during startup")

            # Read output line by line
            try:
                line = self.process.stdout.readline()
                if line:
                    # Check for ready pattern
                    if re.search(ready_pattern, line):
                        print(f"  ✓ Found: {line.strip()}")
                        time.sleep(2)  # Give it a moment to fully initialize
                        return
            except:
                pass

            time.sleep(0.5)

        raise TimeoutError(f"Application didn't start within {timeout}s")

    def run_tests(self):
        """Run HTTP tests"""
        if requests is None:
            print("  Skipping HTTP tests (requests library not installed)")
            return

        base_url = self.spec["endpoint"]["url"]

        for test in self.spec.get("tests", []):
            result = self._run_http_test(base_url, test)
            self.results["tests"].append(result)

            if result["passed"]:
                self.results["passed"] += 1
                print(f"  ✓ {result['name']}")
            elif result.get("skipped"):
                self.results["skipped"] += 1
                print(f"  ⊘ {result['name']} (skipped)")
            else:
                self.results["failed"] += 1
                print(f"  ✗ {result['name']}")
                if result.get("error"):
                    print(f"    {result['error']}")

    def _run_http_test(self, base_url: str, test: Dict) -> Dict:
        """Execute a single HTTP test"""
        result = {
            "name": test["name"],
            "passed": False,
            "skipped": False,
            "error": None,
        }

        if test.get("optional"):
            result["skipped"] = True
            return result

        try:
            url = base_url + test.get("path", "/")
            method = test.get("method", "GET")
            timeout = test.get("timeout", 10)

            response = requests.request(method, url, timeout=timeout)

            # Check status code
            expected_status = test.get("expect_status", 200)
            if response.status_code != expected_status:
                result["error"] = (
                    f"Status {response.status_code}, expected {expected_status}"
                )
                return result

            # Check body contains strings
            if "expect_body_contains" in test:
                for substring in test["expect_body_contains"]:
                    if substring not in response.text:
                        result["error"] = f"Body missing: '{substring}'"
                        return result

            # Check JSON matches golden file
            if "expect_json_file" in test:
                golden_path = self.challenge_dir / test["expect_json_file"]
                if not golden_path.exists():
                    result["error"] = f"Golden file not found: {golden_path}"
                    return result

                with open(golden_path) as f:
                    expected = json.load(f)

                try:
                    actual = response.json()
                    if actual != expected:
                        result["error"] = "JSON doesn't match golden file"
                        return result
                except json.JSONDecodeError as e:
                    result["error"] = f"Invalid JSON response: {e}"
                    return result

            result["passed"] = True

        except requests.Timeout:
            result["error"] = f"Request timeout after {timeout}s"
        except requests.RequestException as e:
            result["error"] = f"Request failed: {e}"
        except Exception as e:
            result["error"] = str(e)

        return result

    def measure_performance(self):
        """Measure web app performance"""
        # TODO: Implement performance benchmarking
        print("  (Performance benchmarking not yet implemented)")


class APIAdapter(WebAppAdapter):
    """Adapter for API services (extends WebAppAdapter)"""
    pass


def main():
    parser = argparse.ArgumentParser(description="Runtime Verification Orchestrator")
    parser.add_argument("--spec", required=True, type=Path, help="Path to runtime-spec.yaml")
    parser.add_argument("--output", required=True, type=Path, help="Output directory to test")
    parser.add_argument("--challenge-dir", required=True, type=Path, help="Challenge directory")
    parser.add_argument("--report", default="runtime-results.json", help="Report output file")

    args = parser.parse_args()

    verifier = RuntimeVerifier(args.spec, args.output, args.challenge_dir)
    results = verifier.run()

    # Write report
    with open(args.report, "w") as f:
        json.dump(results, f, indent=2)

    # Print summary
    print(f"\n{'=' * 50}")
    print("Runtime Verification Results")
    print(f"{'=' * 50}")
    print(f"Passed:  {results['passed']}")
    print(f"Failed:  {results['failed']}")
    print(f"Skipped: {results['skipped']}")

    # Exit with appropriate code
    if results["failed"] > 0:
        print("\n✗ Runtime verification FAILED")
        sys.exit(1)
    elif results["passed"] == 0:
        print("\n⚠ No tests were run")
        sys.exit(1)
    else:
        print("\n✓ Runtime verification PASSED")
        sys.exit(0)


if __name__ == "__main__":
    main()
