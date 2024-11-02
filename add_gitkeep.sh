#!/bin/bash

# Trouve tous les dossiers sans fichiers ni sous-dossiers
find . -type d ! -path "./.git/*" -empty -exec touch {}/.gitkeep \;

echo "Les fichiers .gitkeep ont été ajoutés aux dossiers vides."
