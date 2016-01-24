# atom-svn-status package

__This is early stage work in progress!__

The aspiration is to be a Subversion client in Atom.  The reality is
that there is almost nothing here yet.

This work would not have been possible without
[Atomatigit](https://github.com/diiq/atomatigit).  It solves a similar problem,
and I copied source code from it.  Mucho kudos to the Atomatigit team!  Thanks,
guys.

At this moment you can do cmd+shift+p and then run the "Svn: Status" command.
When you are done looking, run the "Svn: Close" command.

You're supposed to be able to use `j` and `k` to navigate between the entries in
the list, but the styling is not working, so you don't see any effect.

You're also supposed to be able to check some boxes and then "Svn: Commit"
should, well, commit.  But it's not working.

__Warning:__ It's hard to say whether there will ever be anything meaningful
coming out of this, so if you have input, please don't hesitate to take this
over: Contribute here, or create a new Atom package under the same name, or fork
this repo and declare your fork the canonical version.

__Remark:__ There is a similarly named Atom package at
https://github.com/andischerer/atom-svn/, its functionality is different,
though.  But I think Andi is actually working on his software, whereas I'm just
a wannabe.  :-(
