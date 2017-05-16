# one-vm-bootstrap

This OpenNebula VM init script will clone a git repo during start-up in order
to kick off bootstrapping scripts for various custom configurations. This
allows updating context scripts in a repo instead of constantly uploading new
versions as onefiles.

# Usage

Upload one-vm-bootstrap.sh as a ONE file and select the file as a
context "init" script in a VM template. Add the following context variables to
the template:

- **CONTEXT_REPO_URL** - git clone url for a repo containing context scripts

The following variables are optional but may require tweaking (especially
**CONTEXT_REPO_RUN_FILE** depending on the repo layout):

- **CONTEXT_REPO_BRANCH** - repo branch to checkout (*DEFAULT*: master)
- **CONTEXT_REPO_RUN_FILE** - path to run script relative to repo (*DEFAULT*: runcontext.sh)
- **CONTEXT_REPO_RUN_LOG** - path to log file for run (*DEFAULT*: /root/context-repo-run.log)
- **CONTEXT_REPO_DEST_DIR** - destination path for repo clone (*DEFAULT*: /root/context-repo)
- **CONTEXT_REPO_WORK_DIR** - current working directory when running scripts (*DEFAULT*: /root)

On boot this context script will do the following:

1. Clone the repo defined by **$CONTEXT_REPO_URL**
2. Checkout repo branch defined by **$CONTEXT_REPO_BRANCH**
3. Run a script in the repo defined by **$CONTEXT_REPO_RUN_FILE**

# Examples

See the examples directory for a sample script.

Note, the scripts do not need to be in this repo - they can be in an external
repo. This repo (one-vm-bootstrap) is just for the one-vm-bootstrap.sh
script, which must be uploaded to OpenNebula as a onefile.
