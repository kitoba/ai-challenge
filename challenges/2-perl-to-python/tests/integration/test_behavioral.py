"""
Behavioral Equivalence Tests for Perl → Python Challenge

Tests that the modernized Python script produces identical outputs
to the legacy Perl script for the same inputs and options.
"""

import subprocess
import json
from pathlib import Path

# Paths
TESTS_DIR = Path(__file__).parent.parent
CHALLENGE_DIR = TESTS_DIR.parent
EXPECTED_DIR = CHALLENGE_DIR / "expected-outputs"
TEST_INPUT = CHALLENGE_DIR / "test-inputs" / "app.log"

# Candidate's Python script location
CANDIDATE_SCRIPT = CHALLENGE_DIR.parent.parent.parent / "output" / "perl-to-python" / "log_analyzer.py"


def run_candidate_script(args: list[str]) -> tuple[str, int]:
    """
    Run the candidate's Python script with given arguments.
    Returns (stdout, exit_code)
    """
    if not CANDIDATE_SCRIPT.exists():
        raise FileNotFoundError(f"Candidate script not found: {CANDIDATE_SCRIPT}")

    cmd = ["python", str(CANDIDATE_SCRIPT), str(TEST_INPUT)] + args
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout, result.returncode


def load_golden_file(filename: str) -> str:
    """Load a golden output file."""
    path = EXPECTED_DIR / filename
    if not path.exists():
        raise FileNotFoundError(f"Golden file not found: {path}")
    return path.read_text()


class TestErrorOutput:
    """Test error summary output."""

    def test_errors_text_format(self):
        """Test --errors flag produces correct text output."""
        golden = load_golden_file("errors.txt")
        output, exit_code = run_candidate_script(["--errors"])

        assert exit_code == 0, "Script should exit successfully"
        assert output == golden, "Error summary output should match golden file"

    def test_errors_json_format(self):
        """Test --errors --json produces valid JSON matching golden file."""
        golden_text = load_golden_file("errors.json")
        golden_data = json.loads(golden_text)

        output, exit_code = run_candidate_script(["--errors", "--json"])

        assert exit_code == 0
        output_data = json.loads(output)
        assert output_data == golden_data, "Error JSON should match golden file"


class TestWarningOutput:
    """Test warning summary output."""

    def test_warnings_text_format(self):
        """Test --warnings flag produces correct text output."""
        golden = load_golden_file("warnings.txt")
        output, exit_code = run_candidate_script(["--warnings"])

        assert exit_code == 0
        assert output == golden, "Warning summary should match golden file"

    def test_warnings_json_format(self):
        """Test --warnings --json produces valid JSON."""
        golden_text = load_golden_file("warnings.json")
        golden_data = json.loads(golden_text)

        output, exit_code = run_candidate_script(["--warnings", "--json"])

        assert exit_code == 0
        output_data = json.loads(output)
        assert output_data == golden_data


class TestStatistics:
    """Test statistics output."""

    def test_stats_text_format(self):
        """Test --stats flag produces correct statistics."""
        golden = load_golden_file("stats.txt")
        output, exit_code = run_candidate_script(["--stats"])

        assert exit_code == 0
        assert output == golden

    def test_stats_json_format(self):
        """Test --stats --json produces valid JSON with correct counts."""
        golden_text = load_golden_file("stats.json")
        golden_data = json.loads(golden_text)

        output, exit_code = run_candidate_script(["--stats", "--json"])

        assert exit_code == 0
        output_data = json.loads(output)
        assert output_data == golden_data

    def test_default_shows_stats(self):
        """Test that running with no flags shows stats by default."""
        golden = load_golden_file("stats.txt")
        output, exit_code = run_candidate_script([])

        assert exit_code == 0
        assert output == golden, "Default output should be stats"


class TestIPAnalysis:
    """Test IP address analysis output."""

    def test_ips_text_format(self):
        """Test --ips flag shows IP address frequencies."""
        golden = load_golden_file("ips.txt")
        output, exit_code = run_candidate_script(["--ips"])

        assert exit_code == 0
        assert output == golden

    def test_ips_json_format(self):
        """Test --ips --json produces valid JSON."""
        golden_text = load_golden_file("ips.json")
        golden_data = json.loads(golden_text)

        output, exit_code = run_candidate_script(["--ips", "--json"])

        assert exit_code == 0
        output_data = json.loads(output)
        assert output_data == golden_data


class TestUserAnalysis:
    """Test user login analysis output."""

    def test_users_text_format(self):
        """Test --users flag shows user login summary."""
        golden = load_golden_file("users.txt")
        output, exit_code = run_candidate_script(["--users"])

        assert exit_code == 0
        assert output == golden

    def test_users_json_format(self):
        """Test --users --json produces valid JSON."""
        golden_text = load_golden_file("users.json")
        golden_data = json.loads(golden_text)

        output, exit_code = run_candidate_script(["--users", "--json"])

        assert exit_code == 0
        output_data = json.loads(output)
        assert output_data == golden_data


class TestTimingAnalysis:
    """Test request timing analysis output."""

    def test_times_text_format(self):
        """Test --times flag shows timing statistics."""
        golden = load_golden_file("times.txt")
        output, exit_code = run_candidate_script(["--times"])

        assert exit_code == 0
        assert output == golden

    def test_times_json_format(self):
        """Test --times --json produces valid JSON."""
        golden_text = load_golden_file("times.json")
        golden_data = json.loads(golden_text)

        output, exit_code = run_candidate_script(["--times", "--json"])

        assert exit_code == 0
        output_data = json.loads(output)
        assert output_data == golden_data


class TestMultipleOptions:
    """Test combining multiple command-line options."""

    def test_multiple_text_options(self):
        """Test --errors --warnings together."""
        output, exit_code = run_candidate_script(["--errors", "--warnings"])

        assert exit_code == 0
        # Should contain both error and warning sections
        assert "Error Summary" in output or "errors" in output.lower()
        assert "Warning Summary" in output or "warnings" in output.lower()

    def test_all_options_together(self):
        """Test all flags together."""
        output, exit_code = run_candidate_script([
            "--errors", "--warnings", "--stats", "--ips", "--users", "--times"
        ])

        assert exit_code == 0
        # Output should be substantial
        assert len(output) > 100


class TestErrorHandling:
    """Test error handling and edge cases."""

    def test_missing_file_returns_error(self):
        """Test that nonexistent log file produces error exit code."""
        cmd = ["python", str(CANDIDATE_SCRIPT), "nonexistent.log"]
        result = subprocess.run(cmd, capture_output=True, text=True)

        assert result.returncode != 0, "Should exit with error for missing file"

    def test_no_args_shows_usage(self):
        """Test that running with no arguments shows usage."""
        cmd = ["python", str(CANDIDATE_SCRIPT)]
        result = subprocess.run(cmd, capture_output=True, text=True)

        assert result.returncode != 0
        # Should show usage or error message
        assert len(result.stderr) > 0 or "usage" in result.stdout.lower()
