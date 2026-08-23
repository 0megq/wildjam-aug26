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

            dialogData["text"] = ""
            dialogData["set"] = {}
            dialogData["link"] = {}

            print(dialogId)
            for line in lines:
                if line.find("\"") == 0 or line.find("/") == 0:
                    italics = line.find("//")
                    count = 0
                    while italics != -1:
                        if count % 2 == 0:
                            line = line.replace("//", "[i]", 1)
                        else:
                            line = line.replace("//", "[/i]", 1)
                        count += 1
                        italics = line.find("//")
                    dialogData["text"] = line
                elif line.find("set") == 1:
                    varIdx = line.find("$") + 1
                    varEnd = line.find(" ", varIdx)
                    variableName = line[varIdx:varEnd]

                    valIdx = line.find("\"") + 1
                    valEnd = line.find("\"", valIdx)
                    val = line[valIdx:valEnd]

                    if variableName == "agitation":
                        toIdx = line.rfind("to")
                        parIdx = line.find(")", toIdx)
                        val = line[toIdx + 3:parIdx].replace(" ", "")

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