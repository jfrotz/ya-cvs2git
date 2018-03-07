## Example Migration Faults

---
### Symptom - non-ascii checkin comments

<div style='border: 1px; display:block'>
----- pass 2 (CleanMetadataPass) -----
Converting metadata to UTF8...
Encoding 'ascii' failed for string ... doesn\xe2\x80\x99t have these ...
</div>

### Solution - remove non-ascii character strings

  - cd migrate/cvs2git-tmp
  - grep -r "t have these" .
  - $EDITOR $FILE

Replace the \xe2\x80\x99 with a single quote (').
---
### Symptom - both cvs file (,v) and deleted file (Attic/) exist

  - ERROR: <migration file is also a deleted file; you can't have both>

### Solution

  - Delete the Attic/$PROBLEM_FILE.

---
### Symptom - CVS locks

  - A CVS file has a lock present.

### Solution

The standard "unlocked" state is represented in the line "locks; strict;".
Files with this problem only have "locks;" and then a line (in our case) a few lines lower indicating the locked revisions.
The locks line needs needs to be "locks; strict;" and the actual lock line needs to be removed.

Practice on your copy before you change your source ,v files.
