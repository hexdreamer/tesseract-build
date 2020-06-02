# Overview

Scripts are written for zsh.  The unittest framework **shunit2** is written in bash and has some specific requirements to integrate zsh scripts.  These requirements can be found at the bottom of the **test_*.sh** files.

Use **run_tests.sh** to run all tests.

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

Still coming to terms with choosing zsh.  After reading more in <https://wiki.ubuntu.com/DashAsBinSh> and <https://google.github.io/styleguide/shellguide.html#s2.1-file-extensions>, the script will be `build`, and its shebang will be `#!/bin/zsh -f`.

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

## Considerations for Shell Script style

- <https://google.github.io/styleguide/shellguide.html>
- <http://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/>
- <https://wiki.ubuntu.com/DashAsBinSh>

### Wrapping my head around word splitting

<https://unix.stackexchange.com/a/26672/366399>

> Zsh had arrays from the start, and its author opted for a saner language design at the expense of backward compatibility. In zsh (under the default expansion rules) $var does not perfom word splitting; if you want to store a list of words in a variable, you are meant to use an array; and if you really want word splitting, you can write $=var.
>
> ```zsh
> files=(foo bar qux)
> myprogram $files
> ```

<http://zsh.sourceforge.net/FAQ/zshfaq03.html>

> ...
> after which $words is an array with the words of $sentence (note characters special to the shell, such as the ' in this example, must already be quoted), or, less standard but more reliable, turning on SH_WORD_SPLIT for one variable only:
>
> ```zsh
> args ${=sentence}
> ```

[1]: https://scriptingosx.com/2019/06/moving-to-zsh/
[2]: https://insights.stackoverflow.com/trends?tags=bash%2Czsh
[3]: https://github.com/koalaman/shellcheck/wiki/SC2086
[4]: https://unix.stackexchange.com/a/149361/366399
