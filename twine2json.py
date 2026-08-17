import io

def parse_twine(filename: str):
    with open(filename, "r") as file:
        content = file.read()
        blocks = map(lambda block: block.strip(), filter(lambda block: len(block) > 0, content.split('::')))
        
        for block in blocks:
            

            dialogId = -1
            nextWord = block.split()[0]
            try:
                dialogId = int(nextWord)
            except:
                print(f'skipping {nextWord}')
                continue

            print(dialogId)
            for line in block.splitlines()[1:]:
                print(line)



parse_twine("assets/Case1.txt")