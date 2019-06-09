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

The set of git-refs fetched from a fork are also stored in the repository.

By default, they are based on the name of the fork and include all branches
and tags that start with `<name>/`, where `<name>` is the name of the fork.

Additionally, all refs under `refs/notes/devtools` and `refs/devtools` in a
fork are mapped to the corresponding `refs/notes/forks/<name>/devtools` and
`refs/forks/<name>/devtools` refs in the virtual repo.

For example, if a remote repository hosted at `https://github.com/git-appraise`
includes a fork named `ojarjur`, that fork has a branch named `ojarjur/forks`
and a tag named `ojarjur/forks_v1`, then the remote repository accessed via
`forks::https://github.com/git-appraise` will include the following refs:

```
refs/heads/ojarjur/forks
refs/tags/ojarjur/forks_v1
```

It will also include refs under `refs/notes/forks/ojarjur/devtools` and
`refs/forks/ojarjur/devtools` that correspond to all refs under
`refs/notes/devtools` and `refs/devtools` in the fork.
