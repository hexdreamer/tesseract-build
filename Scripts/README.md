# Shells

## zsh

zsh is now the macOS default, and it looks like bash will be going away at some point (but probably not soon enough for the scope of this project). From, [Will bash remain indefinitely?][1]:

> Apple is strongly messaging that you should switch shells. This is different from the last switch in Mac OS X 10.3 Panther, when Apple switched the default to bash, but didn’t really care if you remained on tcsh. In fact, tcsh is still present on macOS.
>
> Apple’s messaging should tell us, that the days of /bin/bash are numbered. Probably not *very* soon, but eventually keeping a more than ten year old version of bash on the system will turn into a liability. The built-in bash had to be patched in 2014 to mitigate the ‘Shellshock’ vulnerability. At some point Apple will consider the cost of continued maintenance too high.

StackOverflow perspective on popularity: [Bash vs. Zsh][2].

### What is sh

From the man page,

> sh is a POSIX-compliant command interpreter (shell).  It is implemented by re-execing as either bash(1), dash(1), or zsh(1) as determined by the symbolic link located at /private/var/select/sh

So, even though I thought I was doing some generic "sh" scripting, there's really no thing.

## Robustness: "correctness", linting

There are some definitive notions about correctness I'm just starting to learn when it comes to shell programming, like "always double-quote your variables", [because][3]:

```sh
$ foo="bar       baz"
$ echo $foo
bar baz
$ echo "$foo"
bar       baz
```

which is only a problem in bash (zsh just doesn't do any splitting/recombining of `$foo`).

Still, I think it's valuable to pick a standard and stick to it.  I've decided to conform my zsh script to the rules of *shellcheck*.  Except shellcheck can't actually lint zsh, it only lints bash, so I'm manually changing the shebang to bash, running the linter, then changing back to zsh before commit.  I think I'll automate this in Git pre-commit hook.

I accept this wonkiness for a better understanding of any shell.  And because bash and zsh are both POSIX, I believe the understandings are transferable.

There's also the benefit of the linter enforcing a formatting standard, which will keep Git commits cleaner.

## Tesseract

Need to debug an issue with `configure` in Tesseract-OCR.  configure is using pkg-config to validate the presence and version of Leptonica:

```sh
$PKG_CONFIG --exists --print-errors "lept >= 1.74"
```

Similar pkg-config commands are used to generate the strings that get passed to `LEPTONICA_CFLAGS` and `LEPTONICA_LIBS`, but pkg-config when run inside configure always errors out.  I can run those pkg-config manually and get the correct output, which I'm hard-coding into the `pre-config` flags for the Tesseract `download_extract_install()` call (which I decided on based on this [answer][4] and trying to pass them as args to configure, but to no avail).

```sh
--pre-config "
    ./autogen.sh; &&
    export LEPTONICA_CFLAGS='-I$Root/include/leptonica'; &&
    export LEPTONICA_LIBS='-L$Root/lib -llept';
" \
```

I'm going to pursue enabling debugging in `./configure` to try and find the point of failure; I'd really like to see pkg-config do its thing.

[1]: https://scriptingosx.com/2019/06/moving-to-zsh/
[2]: https://insights.stackoverflow.com/trends?tags=bash%2Czsh
[3]: https://github.com/koalaman/shellcheck/wiki/SC2086
[4]: https://unix.stackexchange.com/a/149361/366399
