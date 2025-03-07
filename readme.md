# Adding terms to PRO slim 

1. Clone the PRO slim to your Github
2. Add the PR ID to seed.txt in the correct order. (To programmatically sort seed.txt, you can run on the terminal, if you use macOS, `cat seed.txt | sort | uniq > seed.tmp.txt && mv seed.tmp.txt seed.txt`)
3. On your terminal (assuming your diretory is on the repo) run: 'sh odk.sh make all'
4. Make a pull request as usual

If you are updating the PRO slim several times out of the same cloned
repository, be aware that running the `sh odk.sh make all` command (step
3 above) will always forcefully download the most recent version of PRO.
If that is not desired (e.g. if you are sure that you have a recent
enough version, maybe because you last run the command earlier on the
same day), you may call the command as `sh odk.sh make all MIR=false`.
You may only do that if you are the last person to have updated the
slim! If the last update was made by someone else, you _must_ ensure
that you are using a version of PRO that is at least as recent as the
one used for the last update, and the easiest way to ensure that is to
always get the latest version (which is the default behaviour).
