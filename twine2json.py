import io, json

"""Offline processing script to convert twine story in .txt format into a json dictionary.
This json is then read by a gdscript dictionary and converted into the in-game format.
"""

def log(msg):
    pass

def parse_twine(filename: str):
    res = {}
    with open(filename, "r") as file:
        content = file.read()
        # split content into blocks (filtering out empty blocks)
        blocks = filter(
            lambda block: len(block) > 0,
            map(
                lambda block: block.strip(),
                content.split('::')
            )
        )
        
        for block in blocks:
            dialogId = -1

            # get first word in block
            nextWord = block.split()[0]
            try:
                # if it's a number, then we good
                dialogId = int(nextWord)
            except:
                # if not, then throw it away
                log(f'skipping {nextWord}')
                continue

            log(f'parsing {dialogId}')


            dialogData = {}

            # throw away the first line of the block, and remove any empty lines
            lines = list(filter(
                lambda line: len(line.strip()) > 0,
                block.splitlines()[1:]
            ))
            
            # assume the text is in the first line
            dialogData["text"] = lines[0].strip("\"/")

            # remove the first line since we just processed it
            lines = lines[1:]

            dialogData["set"] = {}
            dialogData["link"] = {}

            for line in lines:
                if line.find("set") == 1:
                    varIdx = line.find("$") + 1
                    varEnd = line.find(" ", varIdx)
                    variableName = line[varIdx:varEnd]

                    valIdx = line.find("\"") + 1
                    valEnd = line.find("\"", valIdx)
                    val = line[valIdx:valEnd]

                    dialogData["set"][variableName] = val
                    
                elif line.find("link") == 1:
                    textIdx = line.find("\"") + 1
                    textEnd = line.find("\"", textIdx)
                    textName = line[textIdx:textEnd]

                    nextIdx = line.find("\"", textEnd + 1) + 1
                    nextEnd = line.find("\"", nextIdx)
                    nextName = line[nextIdx:nextEnd]

                    dialogData["link"][textName] = nextName
            

            res[dialogId] = dialogData

    with open(filename.split(".")[0] + ".json", "w") as resFile:
        resFile.write((json.dumps(res, indent=4)))


parse_twine("assets/Case1.txt")