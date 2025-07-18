import os.path
import sys
from util import redo
from util import error
from util import filesystem
from base_classes.build_rule_base import build_rule_base
from shutil import copytree

# Definitions for producing colored text on the terminal
NO_COLOR = "\033[0m"
BOLD = "\033[1m"
RED = "\033[31m"
GREEN = "\033[32m"
if "REDO_TEST_ALL_NO_COLOR" in os.environ and os.environ["REDO_TEST_ALL_NO_COLOR"]:
    PASSED = "PASSED"
    FAILED = "FAILED"
else:
    PASSED = BOLD + GREEN + "PASSED" + NO_COLOR
    FAILED = BOLD + RED + "FAILED" + NO_COLOR


class build_test_all(build_rule_base):
    """
    This build rule looks for unit tests in the directory
    it is passed and recursively below. It then runs all the
    tests in sequence and prints a test report to the terminal
    as the tests are run. Tests are matched by finding either a
    "test.adb" file or a "test.do" file a directory.
    """

    def _write_to_both(self, message):
        """Write message to both stderr and summary file."""
        sys.stderr.write(message)
        self.summary_file.write(message)
        self.summary_file.flush()

    def _build(self, redo_1, redo_2, redo_3):
        pass  # We are overriding build instead since
        # we don't need to usual build boilerplate
        # for test_all

    def build(self, redo_1, redo_2, redo_3):
        import database.setup

        # Figure out build directory location
        directory = os.path.abspath(os.path.dirname(redo_1))

        # Find all build directories below this directory:
        tests = []
        for root, dirnames, files in filesystem.recurse_through_repo(directory):
            if os.sep + "alire" + os.sep in root:
                pass
            elif "test.do" in files or "test.adb" in files or "test.adb.do" in files:
                if ".skip_test" in files:
                    sys.stderr.write("Skipping " + root + "\n")
                else:
                    tests.append(root)

        if not tests:
            sys.stderr.write("No tests found in or below '" + directory + "'.\n")
            error.abort(0)

        # Create summary report file
        build_dir = os.path.join(directory, "build")
        filesystem.safe_makedir(build_dir)
        summary_report_path = os.path.join(build_dir, "test_all_summary.txt")
        self.summary_file = open(summary_report_path, "w")

        # Print the test plan:
        num_tests = "%02d" % len(tests)
        self._write_to_both("Will be running a total of " + num_tests + " tests:\n")
        for number, test in enumerate(tests):
            rel_test = os.path.relpath(test, directory)
            self._write_to_both(
                ("%02d" % (number + 1)) + "/" + num_tests + " " + rel_test + "\n"
            )

        # Turn off debug mode. This isn't really compatible with the
        # unit test print out:
        try:
            del os.environ["DEBUG"]
        except BaseException:
            pass

        # Make a build directory at the top level:
        failed_test_log_dir = os.path.join(directory, "build" + os.sep + "failed_test_logs")
        log_dir = os.path.join(directory, "build" + os.sep + "test_logs")
        filesystem.safe_makedir(failed_test_log_dir)
        filesystem.safe_makedir(log_dir)

        # Run tests:
        exit_code = 0
        self._write_to_both("\nTesting...\n")
        for number, test in enumerate(tests):
            rel_test = os.path.relpath(test, directory)
            self._write_to_both(
                "{0:80}   ".format(
                    (("%02d" % (number + 1)) + "/" + num_tests + " " + rel_test)[:80]
                )
            )
            database.setup.reset()
            try:
                test_log = os.path.join(log_dir, rel_test.replace(os.sep, "_") + ".log")
                redo.redo([os.path.join(test, "test"), "1>&2", "2>" + test_log])
                self._write_to_both(" " + PASSED + "\n")
            except BaseException:
                exit_code = 1
                self._write_to_both(" " + FAILED + "\n")

                # On a failed test, save off the test logs for inspection. This is
                # especially useful on a remote CI server.
                try:
                    copytree(
                        os.path.join(test, "build" + os.sep + "log"),
                        os.path.join(failed_test_log_dir, test.replace(os.sep, "_"))
                    )
                except BaseException:
                    pass

        self.summary_file.close()
        error.abort(exit_code)

    # No need to provide these for "redo test_all"
    # def input_file_regex(self): pass
    # def output_filename(self, input_filename): pass
