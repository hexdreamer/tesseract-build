## zsh
zsh is now the macOS default, and it looks like bash will be going away at some point (but probably not soon enough for the scope of this project). From, [Will bash remain indefinitely?][1]:

> Apple is strongly messaging that you should switch shells. This is different from the last switch in Mac OS X 10.3 Panther, when Apple switched the default to bash, but didn’t really care if you remained on tcsh. In fact, tcsh is still present on macOS.
>
> Apple’s messaging should tell us, that the days of /bin/bash are numbered. Probably not *very* soon, but eventually keeping a more than ten year old version of bash on the system will turn into a liability. The built-in bash had to be patched in 2014 to mitigate the ‘Shellshock’ vulnerability. At some point Apple will consider the cost of continued maintenance too high.

StackOverflow perspective on popularity: [Bash vs. Zsh][2].

## Robustness: "correctness", linting
There are some definitive notions about correctness I'm just starting to learn when it comes to shell programming, like "always double-quote your variables", [because][3]:

    $ foo="bar       baz"
    $ echo $foo
    bar baz
    $ echo "$foo"
    bar       baz

which is only a problem in bash (zsh just doesn't do any splitting/recombining of `$foo`).

Still, I think it's valuable to pick a standard and stick to it.  I've decided to conform my zsh script to the rules of *shellcheck*.  Except shellcheck can't actually lint zsh, it only lints bash, so I'm manually changing the shebang to bash, running the linter, then changing back to zsh before commit.  I think I'll automate this in Git pre-commit hook.

I accept this wonkiness for a better understanding of any shell.  And because bash and zsh are both POSIX, I believe the understandings are transferable.

There's also the benefit of the linter enforcing a formatting standard, which will keep Git commits cleaner.

[1]: https://scriptingosx.com/2019/06/moving-to-zsh/
[2]: https://insights.stackoverflow.com/trends?tags=bash%2Czsh
[3]: https://github.com/koalaman/shellcheck/wiki/SC2086