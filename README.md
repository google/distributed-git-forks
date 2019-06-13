# Distributed management of git forks

This repository implements distributed management of git forks.

By "forks", we mean remote repositories which are recorded in the
repository itself, making them easy to share and use.

By storing the collection of forks in the repository, we effectively
define a virtual repository that is composed of all the forks.

This, in turn, lets a repository owner grant contributors fine-grained
permissions on this virtual repository by adding their forks rather
than by giving them permission to push to the main repository.

Since fetching from forks is handled on the client side, no server
side support is required, and contributors can collaborate across
multiple, disjoint git hosting providers.

## Disclaimer

This is not an official Google product.

## Provided tools

This repository provides two tools for dealing with forks:

1. A git subcommand called "fork" that can be used to add, list,
   and delete entries from the collection of forks.
2. A git remote helper that can be used to pull from all of the
   forks of a repository.

## Installation

To install these tools, simply copy the two provided scripts
(`git-fork` and `git-remote-forks`) into some directory in your path.

The `git-remote-forks` tool requires Bash version 4. OSX comes with
version 3 of Bash, so you will have to install the newer version in
order to use the tool on a Mac.

## Example usage

### Adding a repository with all of its forks as a remote

To add a repository with forks as a remote, append "forks::" to the
repository URL.

For example, to add a remote for the `git-appraise` repository, with
all of its forks, run:

```sh
git remote add origin forks::https://github.com/google/git-appraise
```

Then, you can pull from all of those forks with the usual
command of `git pull origin`.

### Managing forks

The git `fork` subcommand is modelled after the `remote` subcommand.

To list the forks, call `git fork` with no arguments.

To add a fork, call `git fork add`, specifying a unique name for 
the fork and its URL:

```sh
git fork add [-o <OWNER_EMAIL_ADDRESS>]* <NAME> <FETCH_URL>
```

To remove a fork, call:

```sh
git fork remove <NAME>
```

Finally, since the goal is for the list of forks to be distributed,
you need to be able to push this collection to and pull it from a
remote repository.

To push the collection of forks:

```sh
git fork push <REMOTE>
```

... and to pull them:

```sh
git fork pull <REMOTE>
```

### Pushing to the virtual repository through a fork

The virtual repository is read-only. Rather than pushing to it directly,
you push to your fork. Then, anyone pulling from the virtual repository
will fetch the corresponding refs from your fork.

The set of refs fetched from each fork is also stored in the repository.

By default, they are based on the name of the fork and include all branches
and tags that start with `<name>/`, where `<name>` is the name of the fork.

For example, if there is a fork named `my-fork` and it has a branch named
`my-fork/my-branch` and a tag named `my-fork/my-tag`, then both that branch
and that tag will appear in the virtual repository.

Additionally, git notes refs from a fork are mapped to the virtual
repository under `refs/notes/forks/<fork-name>/`.

Finally, all refs from a fork (including branches, tags, and notes)
are mapped to the virtual repository under `refs/forks/<fork-name>/`.
This ensures that every ref from the fork is accessible via the
virtual repo, even if they do not match one of the rules above.
