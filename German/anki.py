import os
import csv

def extract_words_from_md():
    words_list = []

    # Loop through all .md files in the current directory
    for filename in os.listdir('.'):
        if filename.endswith('.md'):
            with open(filename, 'r', encoding='utf-8') as file:
                lines = file.readlines()

            i = 0
            while i < len(lines):
                line = lines[i].strip()

                # Look for the #words-learnt marker
                if line.lower() == "#words-learnt":
                    i += 1
                    # Collect following lines until an empty line
                    while i < len(lines) and lines[i].strip():
                        entry = lines[i].strip()
                        words_list.append(entry)
                        i += 1
                i += 1

    return words_list


def format_words(words_list):
    formatted = []
    for entry in words_list:
        # Split the entry into two parts around ' - '
        if ' - ' in entry:
            front, back = entry.split(' - ', 1)
            formatted.append([front.strip(), back.strip()])
    return formatted


def write_to_csv(formatted_words, output_file='anki_flashcards.csv'):
    with open(output_file, 'w', encoding='utf-8', newline='') as csvfile:
        writer = csv.writer(csvfile)
        for word_pair in formatted_words:
            writer.writerow(word_pair)
    print(f"✅ CSV file created: {output_file} ({len(formatted_words)} entries)")


if __name__ == "__main__":
    words = extract_words_from_md()
    formatted = format_words(words)
    write_to_csv(formatted)
