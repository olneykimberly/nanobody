#!/usr/bin/python3

# create a new output file
outfile = open('config.json', 'w')

# get all sample names
allSamples = list()
numSamples = 0

with open('sampleReadGroupInfo.txt', 'r') as infile:
    for line in infile:
        numSamples += 1

        line = line.replace(".", "_")
        split = line.split()
        sampleAttributes = split[0].split('_')  # nAB_Abeta1_1_CL_Whole_C1_WMGAS_A43777_SC2134209-SC3_AGAGTATCAG_L001_R1_001.fastq.gz
                                                #  E1_BR.FCHVC2VDRXY_L1_R1_ITAAGTGGT-CTTAAGCC.fastq.gz pigID_tissue.sequencer_lane_read_X-X.fastq.gz
        # create a shorter sample name
        stemName = sampleAttributes[0] + '_' + sampleAttributes[1]
        allSamples.append(stemName)

# create header and write to outfile
header = '''{{
    "Commment_Input_Output_Directories": "This section specifies the input and output directories for scripts",
    "rawReads" : "../../fastq/",
    "rawQC" : "../../rawQC/",
    "trimmedReads" : "../../trimmedReads/",
    "trimmedQC" : "../../trimmedQC/",
    "aligned" : "../../aligned/",
    "bamstats" : "../../bamstats/",

    "Comment_Reference" : "This section specifies the location of the reference genome",

    "Comment_Sample_Info": "The following section lists the samples that are to be analyzed",
    "sample_names": {0},
'''
outfile.write(header.format(allSamples))

# config formatting
counter = 0
with open('sampleReadGroupInfo.txt', 'r') as infile:
    for line in infile:
        counter += 1
        # store sample name and info from the fastq file
        split = line.split()
        base = split[0]
        base = base.replace(".fastq.gz", "")
        sampleName1 = base
        sampleName2 = sampleName1.replace("R1","R2")
        base = base.replace("_R1_001", "")
        sampleInfo = split[1]

        # make naming consistent, we will rename using only underscores (no hyphens)
        line = line.replace(".", "_")
        split = line.split()
        sampleAttributes = split[0].split('_')  # project_uniqueNum_1_tissue_group_XX_XX_sequencer_adapter_lane_read_001.fastq.gz

        # create a shorter sample name
        stemName = sampleAttributes[0] + '_' + sampleAttributes[1] 
        shortName1 = stemName + '_R1'
        shortName2 = stemName + '_R2'

        # break down fastq file info
        # @A00127:312:HVNLJDSXY:2:1101:2211:1000
        # @<instrument>:<run number>:<flowcell ID>:<lane>:<tile>:<x-pos>:<y-pos>
        sampleInfo = sampleInfo.split(':')
        instrument = sampleInfo[0]
        runNumber = sampleInfo[1]
        flowcellID = sampleInfo[2]

        lane = sampleInfo[3]
        ID = stemName  # ID tag identifies which read group each read belongs to, so each read group's ID must be unique
        SM = stemName  # Sample
        PU = flowcellID + "." + lane  # Platform Unit
        LB = stemName

        out = '''
    "{0}":{{
        "fq_path": "../../fastq/",
        "fq1": "{1}",
        "fq2": "{2}",
        "fq_R1": "{3}",
        "fq_R2": "{4}",
        "ID": "{5}",
        "SM": "{6}",
        "PU": "{7}",
        "LB": "{8}",
        "PL": "Illumina"
        '''
        outfile.write(out.format(stemName, sampleName1, sampleName2, shortName1, shortName2, stemName, stemName, PU, LB))
        if (counter == numSamples):
            outfile.write("}\n}")
        else:
            outfile.write("},\n")
outfile.close()
