//
//  Localized.swift
//  Flashcards
//

// swiftlint:disable line_length file_length

import Localized

#localized(default: "en", yml: """
export(title):
    en: Export Set \\"(title)\\"
    de: Exportiere das Set \\"(title)\\"

addSet:
    en: Add Set
    de: Set hinzufügen

sets:
    en: Sets
    de: Sets

newWindow:
    en: New Window
    de: Neues Fenster

closeWindow:
    en: Close Window
    de: Fenster schliessen

about:
    en: About Flashcards
    de: Info zu Flashcards

mainMenu:
    en: Main Menu
    de: Hauptmenü

viewMenu:
    en: View
    de: Ansicht

filter:
    en: Filter...
    de: Filtern ...

noFlashcards:
    en: No flashcards available
    de: Keine Karteikarten verfügbar

generateExam:
    en: Generate a Preparation Exam
    de: Erstelle eine Vorbereitungsprüfung

generateExamDescription(title):
    en: Spot last mistakes before your exam about \\"(title)\\"
    de: Finde letzte Fehler vor deiner Prüfung zu \\"(title)\\"

answerWithBack:
    en: Answer With Back
    de: Antworte mit der Rückseite

numberOfQuestions:
    en: Number of Questions
    de: Anzahl Fragen

testDescription(count, total):
    en: Testing (count) of (total) Flashcards
    de: Teste (count) von (total) Karteikarten

createTest:
    en: Create Test
    de: Prüfung erstellen

solveTest:
    en: Solve Test
    de: Test lösen

fullScore:
    en: Full Score!
    de: Volle Punktzahl!

score(score, points):
    en: (score) (points)
    de: (score) (points)

point:
    en: Point
    de: Punkt

points:
    en: Points
    de: Punkte

maxScore:
    en: Maximum Score
    de: Maximale Punktzahl

noScoreData:
    en: "-"
    de: "-"

scoreInstructions:
    en: Scroll down to check your answers
    de: Überprüfe deine Antworten weiter unten

scoreLabel:
    en: Score
    de: Punktzahl

scoreRowLabel:
    en: Your Score
    de: Deine Punktzahl

check:
    en: Check
    de: Überprüfen

finishTest:
    en: Finish Test
    de: Test beenden

star:
    en: Star
    de: Stern

tags:
    en: Tags
    de: Tags

allFlashcards:
    en: All Flashcards
    de: Alle Karteikarten

flashcardsWithTags:
    en: Flashcards With Tags
    de: Karteikarten mit Tags

study(title):
    en: Study \\"(title)\\"
    de: Lerne \\"(title)\\"

studyDescription:
    en: Repeat each flashcard until you remember it
    de: Lerne bis du jede Karteikarte beherrscht

initialDifficulty:
    en: Initial Difficulty
    de: Anfangsschwierigkeit

initialDifficultyDescription:
    en: Set the minimum number of repetitions per flashcard
    de: Lege die minimale Anzahl Wiederholungen pro Karteikarte fest

studySummary(count, total):
    en: Studying (count) of (total) Flashcards
    de: Lerne (count) von (total) Karteikarten

startStudyMode:
    en: Start Study Mode
    de: Starte den Lernmodus

studySettings:
    en: Study Settings
    de: Einstellungen zum Lernmodus

continueStudying:
    en: Continue Studying
    de: Lernen fortsetzen

terminateStudyMode:
    en: Terminate Study Mode
    de: Lernmodus beenden

_continue:
    en: Continue
    de: Fortfahren

makeIncorrect:
    en: Make Incorrect
    de: Als falsch markieren

makeCorrect:
    en: Make Correct
    de: Als richtig markieren

answer:
    en: Answer
    de: Antwort

solution:
    en: Solution
    de: Lösung

correct:
    en: Correct!
    de: Korrekt!

yourAnswer:
    en: Your Answer
    de: Deine Antwort

editSet:
    en: Edit Set
    de: Set bearbeiten

keywords:
    en: Keywords
    de: Schlüsselwörter

keyword:
    en: Keyword
    de: Schlüsselwort

keywordsDescription:
    en: Keywords simplify the search for sets
    de: Schlüsselwörter vereinfachen die Suche nach Sets

add(element):
    en: Add (element)
    de: (element) hinzufügen

remove(element):
    en: Remove (element)
    de: (element) entfernen

pasteText:
    en: Paste Text
    de: Text einfügen

switchFrontBack:
    en: Switch Front and Back
    de: Vorder- und Rückseite vertauschen

exportQuizletSet:
    en: Export Quizlet Set
    de: Quizlet-Set exportieren

quizletDescription:
    en: "Export a Quizlet set under <tt><b> ⋯ > Export</b></tt>. Using the default configuration, copy the text."
    de: "Exportiere ein Quizlet-Set unter <tt><b> ⋯ > Export</b></tt>. Kopiere den Text mit der Standardkonfiguration."

exportAnkiDeck:
    en: Export Anki Deck
    de: Anki Deck exportieren

ankiDescription:
    en: "Export decks under <tt><b> File > Export</b></tt>. Select the export format <tt><b> Cards in Plain Text </b></tt>. Uncheck <tt><b>Include HTML and media references</b></tt>. Copy the content of the text file."
    de: "Exportiere Decks unter <tt><b> File > Export</b></tt>. Wähle das Format <tt><b> Cards in Plain Text </b></tt>. Deaktiviere <tt><b>Include HTML and media references</b></tt>. Kopiere den Inhalt der Textdatei."

cancel:
    en: Cancel
    de: Abbrechen

_import:
    en: Import
    de: Importieren

betweenTermDefinition:
    en: Between Term and Definition
    de: Zwischen Term und Definition

betweenRows:
    en: Between Rows
    de: Zwischen Reihen

copy:
    en: Copy
    de: Kopieren

deleteSet:
    en: Delete Set
    de: Set löschen

exportSet:
    en: Export Set
    de: Set exportieren

done:
    en: Done
    de: Fertig

title:
    en: Title
    de: Titel

tagsDescription:
    en: Organize and study flashcards in groups
    de: Organisiere und lerne Karteikarten in Gruppen

tag:
    en: Tag
    de: Tag

starDescription:
    en: A special tag that can be set while studying
    de: Ein spezielles Tag, das während des Lernens gesetzt werden kann

addFlashcard:
    en: Add Flashcard
    de: Karteikarte hinzufügen

importFlashcards:
    en: Import Flashcards
    de: Karteikarten importieren

front:
    en: Front
    de: Vorderseite

back:
    en: Back
    de: Rückseite

flashcard(index):
    en: Flashcard (index)
    de: Karteikarte (index)

deleteFlashcard:
    en: Delete Flashcard
    de: Karteikarte löschen

delete:
    en: Delete
    de: Löschen

deleteTitle(title):
    en: Delete \\"(title)\\"?
    de: \\"(title)\\" löschen?

deleteDescription:
    en: There is no undo. The flashcards will be lost.
    de: Die Karteikarten werden nicht wiederherstellbar sein.

filterSets:
    en: Filter Sets
    de: Sets filtern

noSelection:
    en: No Selection
    de: Keine Auswahl

noSelectionDescription:
    en: Select a set in the sidebar.
    de: Wähle ein Set in der Seitenleiste aus.

noSets:
    en: No Sets
    de: Keine Sets verfügbar

noSetsDescription:
    en: Create a new set using the <b>+</b> button in the sidebar.
    de: Erstelle mit dem <b>+</b>-Knopf in der Seitenleiste ein neues Set.

overview:
    en: Overview
    de: Übersicht

studySwitcher:
    en: Study
    de: Lernen

test:
    en: Test
    de: Testen

newSet:
    en: New Set
    de: Neues Set

question(index):
    en: Question (index)
    de: Frage (index)

quizlet:
    en: Quizlet
    de: Quizlet

anki:
    en: Anki
    de: Anki

showTutorial:
    en: Show Tutorial
    de: Tutorial zeigen

comma:
    en: Comma
    de: Komma

tab:
    en: Tab
    de: Tab

newLine:
    en: New Line
    de: Neue Zeile

semicolon:
    en: Semicolon
    de: Semikolon
""")

// swiftlint:enable line_length file_length
