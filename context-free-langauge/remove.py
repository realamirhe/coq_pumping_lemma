import os

for file in os.listdir('.'):
  if (
    file != '_CoqProject'
    and file != 'README.md'
    and file != '.gitignore'
    and file != 'remove.py'
    and os.path.isfile(file)
    and not file.endswith(".v")
  ):
    os.remove(file)