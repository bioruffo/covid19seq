#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 31 20:26:46 2020

@author: roberto
"""

import re
import argparse


# Helper functions to translate string operators into expressions
def lesser (a, b):
    # a, b are strings
    try:
        return float(a) < float(b)
    except ValueError:
        return None

def higher (a, b):
    # a, b are strings
    try:
        return float(a) > float(b)
    except ValueError:
        return None

def unequal(a, b):
        # a, b are strings
    return a.strip() != b.strip()

def equal (a, b):
    # a, b are strings
    if a.strip() == b.strip():
        return True
    else:
        try:
            fa, fb = float(a), float(b)
        except ValueError:
            return None
        if fa == fb:
            return True
        else:
            try:
                fa, fb = int(a), int(b)
                if fa == fb:
                    return True
                else:
                    return False
            except ValueError:
                return False
  

def interpret(string):
    # Interpret the filter expression for BLAST results
    search = re.search('(\d+) ?([<=> ]+) ?(\S+)', string)
    if search.groups() is None or len(search.groups()) != 3:
        print('BLAST table parameters not understood: "' + string + '"')
        print('Format: <parameter_line> <operators> <value>')
        print('Example: 10 < 0.001')
        exit()
    try:
        parameter = int(search.groups()[0])
    except ValueError:
        print('First BLAST table argument must be column position (0-based)')
        exit()
    op = search.groups()[1].replace(' ', '')
    if op in ('<>', '!='):
        operators = [unequal]
    else:
        operators = [{'<':lesser, '=':equal, '>':higher}[exp] for exp in op]
    value = search.groups()[2]
    return (parameter, operators, value)
        

def filter_blast_table(bl_args):
    # Apply the filter to a BLAST table, return sequence IDs that match
    filename = bl_args[0]
    bl_args = ' '.join(bl_args).split(' ')
    retcol = 1 # we return the 1-st column
    sstart = 8
    send = 9
    if len(bl_args) > 2:
        parameter, operators, value = interpret(' '.join(bl_args[1:]))
    else:
        parameter = None
    names = []
    with open(filename, 'r') as f:
        data = f.read().splitlines()
        startline = [0, 1][data[0].startswith("qseqid")] #handle header
        for line in data[startline:]:
            split = line.split('\t')
            if len(split) > parameter:
                if any([exp(split[parameter], value) for exp in operators]):
                    names.append([split[retcol].strip(), int(split[sstart]), int(split[send])])
                elif any([exp(split[parameter], value) is None for exp in operators]):
                    print("Unable to evaluate line:\n"+line)
                    for exp in operators:
                        print('Evaluating if:')
                        print(split[parameter])
                        print(exp.__name__)
                        print(value)
                        print("Result:", exp(split[parameter], value))
                    exit()
    return names




def translate(seq): 
    # Translate codons (DNA style) into aminoacids.
    # Table from: https://www.geeksforgeeks.org/dna-protein-python-3/
    # Added translation for final-N codes to rescue some data
    table = { 
        'ATA':'I', 'ATC':'I', 'ATT':'I', 'ATG':'M', 
        'ACA':'T', 'ACC':'T', 'ACG':'T', 'ACT':'T', 'ACN': 'T',
        'AAC':'N', 'AAT':'N', 'AAA':'K', 'AAG':'K', 
        'AGC':'S', 'AGT':'S', 'AGA':'R', 'AGG':'R',                  
        'CTA':'L', 'CTC':'L', 'CTG':'L', 'CTT':'L', 'CTN': 'L',
        'CCA':'P', 'CCC':'P', 'CCG':'P', 'CCT':'P', 'CCN': 'P',
        'CAC':'H', 'CAT':'H', 'CAA':'Q', 'CAG':'Q', 
        'CGA':'R', 'CGC':'R', 'CGG':'R', 'CGT':'R', 'CGN': 'R',
        'GTA':'V', 'GTC':'V', 'GTG':'V', 'GTT':'V', 'GTN': 'V',
        'GCA':'A', 'GCC':'A', 'GCG':'A', 'GCT':'A', 'GCN': 'A',
        'GAC':'D', 'GAT':'D', 'GAA':'E', 'GAG':'E', 
        'GGA':'G', 'GGC':'G', 'GGG':'G', 'GGT':'G', 'GGN': 'G',
        'TCA':'S', 'TCC':'S', 'TCG':'S', 'TCT':'S', 'TCN': 'S',
        'TTC':'F', 'TTT':'F', 'TTA':'L', 'TTG':'L', 
        'TAC':'Y', 'TAT':'Y', 'TAA':'_', 'TAG':'_', 
        'TGC':'C', 'TGT':'C', 'TGA':'_', 'TGG':'W' 
    } 
    protein = []
    if len(seq)%3 == 0: 
        for i in range(0, len(seq), 3): 
            codon = seq[i:i+3] 
            protein.append(table.get(codon, 'X'))
    return ''.join(protein)



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', required=True) # Input multiFASTA
    parser.add_argument('-o', '--output', required=True) # Output multiFASTA
    namesgroup = parser.add_mutually_exclusive_group(required=True) # IDs  list
    namesgroup.add_argument('-n', '--names') # IDs list from command line
    namesgroup.add_argument('-f', '--file') # IDs list from file
    namesgroup.add_argument('-b', '--blasttable', nargs = '+') #IDs list from BLAST table
    modgroup = parser.add_mutually_exclusive_group()
    modgroup.add_argument('-c', '--cut') # Only keep matching sequence
    modgroup.add_argument('-t', '--translate') # Translate matching sequence
    parser.add_argument('-p', '--purge_ambiguous') # Remove seqs with N, X
    
    args = parser.parse_args()
    
    if (args.cut or args.translate) and not args.blasttable:
        print("cut or translate will only work on BLAST tables -b, not on -n or -f.")
        exit()
    
    if args.blasttable:
        names = filter_blast_table(args.blasttable)
    elif args.file:
        with open(args.file, 'r') as f:
            names = [[x.strip(), None, None] for x in f.read().splitlines()] # TODO add seq boundaries
    elif args.names:
        names = [[x.strip(), None, None] for x in args.names.split(',')]  # TODO add seq boundaries
    else:
        print("No match provided.")
        exit()
    print('Collected', len(names), 'sequence IDs.')
    
    names_set = set([n[0] for n in names])
    if len(names) != len(names_set):
        print("Some sequences have multiple hits in the table, this version " \
              "will discard seqs with multiple hits (try filtering though).")
        print("Excluding the following non-unique names:")
        allnames = [n[0] for n in names]
        for name in allnames:
            if allnames.count(name) > 1 and name in names_set:
                print(name)
                names_set.discard(name)
                
    if args.cut or args.translate:
        names = dict([(n[0], (n[1], n[2])) for n in names])
    with open(args.output, 'w') as o:
        purged = 0
        currname = ''
        currseq = []
        split = 80
        hit = False
        for line in open(args.input, 'r'):
            if hit:
                if line.startswith('>'):
                    hit = False
                    to_purge = False
                    currseq = ''.join(currseq).replace(' ', '')
                    if args.cut or args.translate:
                        currseq = currseq[names[currname][0]-1:names[currname][1]]
                        currseq = currseq.upper()
                        if "N" in currseq:
                            print("Warning:", currname, "Found", currseq.count("N"), "'N' in sequence")
                            to_purge = True
                    if args.translate:
                        assert len(currseq) % 3 == 0
                        currseq = translate(currseq)
                    if "X" in currseq:
                        print("Warning:", currname, "Found", currseq.count("X"), "undeterminate aa in translated sequence")
                        to_purge = True
                    if "_" in currseq:
                        print("Attention:", currname, "Found", currseq.count("_"), "STOP codons in translated sequence:")
                    if not (args.purge_ambiguous and to_purge):
                        o.write('>'+currname+'\n')
                        o.write(''.join([currseq[i:i+split]+'\n' \
                                         for i in range(0, len(currseq), split)]))
                    else:
                        purged += 1
                    currname = ''
                    currseq = []
                    to_purge = False

                else:
                    currseq.append(line.strip())
            if not hit and line.startswith('>'):
                linename = line[1:].strip()
                if linename in names_set:
                    hit = True
                    currname = line.strip()[1:]

    if args.purge_ambiguous:
        print("Total number of purged sequences: {}/{}".format(purged, len(names)))
    print("Valid sequences:", len(names) - purged)
