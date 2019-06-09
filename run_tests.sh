#!/bin/bash -e
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Setup our path so that the local binaries are available
PATH="${PATH}:$(pwd)"

# Set up our test directories and automatically cleanup on exit
maindir=$(pwd)
test_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'git-remote-forks')
trap "{ cd ${maindir}; rm -rf ${test_dir}; }" EXIT

test_upstream="${test_dir}/upstream"
test_fork1="${test_dir}/fork1"
test_fork2="${test_dir}/fork2"

setup_repos() {
  echo "Setting up remote repositories..."
  mkdir -p "${test_upstream}"
  cd "${test_upstream}"
  git init 2>/dev/null >&2
  echo "# Example README" >> README.md
  git add ./ 2>/dev/null >&2
  git commit -a -m 'Initial commit with a README file' 2>/dev/null >&2
  # We include one invalid fork to verify that the tool is resilient
  # to any individual fork being unavailable
  git fork add not-found /dev/null

  echo "Setting up the first test fork..."
  git clone "forks://${test_upstream}" "${test_fork1}" >&2

  cd "${test_upstream}"
  git fork add fork1 "${test_fork1}"

  echo "Setting up the second test fork..."
  mkdir -p "${test_fork2}"
  cd "${test_fork2}"
  git init
  git remote add origin "forks::${test_upstream}" >&2
  git fetch origin

  cd "${test_upstream}"
  git fork add fork2 "${test_fork2}"
  git fork
}

exit_with_message() {
  echo $'\t'"$?: $1"
  exit 1
}

test_pull_from_forks() {
  cd "${test_fork1}"
  git checkout -b fork1/test-branch
  echo "Second line of the README" >> README.md
  git add ./ 2>/dev/null >&2
  git commit -a -m 'Second commit with a README file update' 2>/dev/null >&2

  cd "${test_fork2}"
  echo "Listing the remote refs from ${test_fork2}..." >&2
  git ls-remote origin >&2 || exit_with_message "failed to list the remote refs from origin..."

  echo "Fetching from a remote with forks..." >&2
  git fetch >&2
  fork_commit=$(git show-ref "refs/remotes/origin/fork1/test-branch" | cut -d ' ' -f 1)
  git cat-file -p "${fork_commit}"
}

setup_repos || exit_with_message "setting up the test repositories failed"
test_pull_from_forks || exit_with_message "testing pulling from a fork failed"
