## Example Faults - Non-ascii checking comment encoding

### Symptom

----- pass 2 (CleanMetadataPass) -----
Converting metadata to UTF8...
Encoding 'ascii' failed for string ... doesn\xe2\x80\x99t have these ...

### Solution

cd migrate/cvs2git-tmp
grep -r "t have these" .
$EDITOR $FILE

Replace the \xe2\x80\x99 with a single quote (').

### Symptom

ERROR: <migration file is also a deleted file; you can't have both>

### Solution

Delete the Attic/$PROBLEM_FILE.
