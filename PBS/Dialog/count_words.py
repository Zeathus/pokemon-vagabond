from os import listdir
from os.path import isfile, join
import re

all_files = [f for f in listdir(".") if isfile(join(".", f))]

total_words = 0

for file in all_files:
    with open(file, "r") as f:
      file_words = 0
      for line in f.readlines():
         if re.search("^ *>", line):
            line = re.sub("^ *> *", "", line)
            line = line.replace("\n", "")
            file_words += len(line.split(" "))
         elif re.search("^ *\?>", line):
            line = re.sub("^ *\?> *", "", line)
            line = line.replace("\n", "")
            file_words += len(line.split(" "))
         elif re.search("^ */(choice|cancelchoice|ifchoice)", line):
            line = re.sub("^ */(choice|cancelchoice|ifchoice) *", "", line)
            line = line.replace("\n", "")
            file_words += len(line.split(" "))
      print(f"{file}: {file_words}")
      total_words += file_words

print(f"TOTAL: {total_words}")