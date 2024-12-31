# Changelog for `install.sh` (Unreleased)

## **v1.0.0** - Original version by amidevous
- Detects the operating system (CentOS, Fedora, Ubuntu, or others) and retrieves version and architecture details.
- Downloads `install-dep.sh` to `/tmp/` and executes it.
- Downloads the XUI release archive to `/root/`, extracts it, and prepares the files.
- Executes a Python script (`install.python3`) to finalize the installation.

---

## **v1.1.0** - First forked version
- **Enhanced flexibility**:
  - Introduced global variables (`GH`, `GH_USER`, `GH_REPO`, `GH_RAW`) for easy customization in case of forks.
- **Added `latest.ver`**:
  - Used to fetch the latest version of XUI.
- **Improved messaging**:
  - Added messages indicating if the script was run as a regular user or root.
- **Secured execution**:
  - Used `/tmp/` for downloading and executing temporary files.

---

## **v1.2.0** - Current version (Unreleased, untested)
- **Centralized root privilege handling**:
  - Added `check_root` function to relaunch the script with `sudo` if needed.
  - Included humorous messages ("I am Groot!" and "I am Root!") for user feedback.
- **Organized execution**:
  - Separated user-mode and root-mode tasks.
  - Temporary files are stored in a secure, automatically cleaned directory.
- **Improved usability**:
  - Added traps to ensure temporary files are deleted after execution.
  - Enhanced clarity in messages regarding the script's execution status.
- **Global variables for flexibility**:
  - Simplified future forks and customizations.

---

# To-Do List
- **v1.3.0**:
  - Implement automatic updates for the script using a new `script.ver` file.
  - Add hash checks to verify the integrity of downloaded files.
- **v1.4.0**:
  - Refactor `install.python3` to minimize Python usage and rely more on Bash.
