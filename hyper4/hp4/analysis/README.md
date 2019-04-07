# HyPer4 Analysis Tools

The tools in this directory automate the analysis of HyPer4.  Currently implemented:

1. gen\_configs.sh: Generates HyPer4 source code configurations for a range of match-action stages and maximum number of primitives permitted per stage.  All configurations are placed in their own folder, hp4/p4src/test/config\_XY, where X is the maximum number of stages and Y is the maximum number of primitives per stage.  To use this script, include a value for X as the first command line argument and a value for Y as the second.  All configurations config\_<1 ... X><1 ... Y> will be generated.  At the same time, gen\_configs.sh invokes CLOC to count the lines of code, generating two reports in results\_sum.csv and results\_byfile.csv.  These are parsed by locs\_reporter.py and locs\_reporter\_prims.py respectively.  The last thing gen\_configs.sh does for each configuration is use grep to count the number of table declarations across all .p4 files in the configuration.
2. locs\_reporter.py: Generates a summary .csv report, results\_sum.csv, of the lines of code for every configuration of HyPer4 in the hp4/p4src/test directory.
3. locs\_reporter\_prims.py: Generates a summary .csv report, results\_prims.csv, of the averages lines of code required per implemented primitive for every configuration of HyPer4 in the hp4/p4src/test directory.  Assumes that the currently implemented primitives are modify\_field, add\_header, add\_to\_field, truncate, and drop.
4. tables\_reporter.py: Generates a summary .csv report, results\_tables.csv, of the number of table declarations present in every configuration of HyPer4 in the hp4/p4src/test directory.
5. phv\_reporter.py: Packet Header Vector reporter; totals the widths of the header instances declared in HyPer4.  This tool does not look in a test/config directory but rather scans the source starting at hp4/p4src/hp4.p4 and continuing with all files in hp4/p4src/includes.
6. tern\_match\_reporter.py: Generates a .csv report of the ternary matches involved in each packet in a nano log file.  Warning, the reported averages for bits involved in ternary matches may be a little inaccurate because we do not always get 100% of the events recorded in the nano log file.  But it should be easy to spot discrepancies in the .csv report.

## Instructions

To use locs\_reporter, locs\_reporter\_prims, or tables\_reporter, first run gen\_configs.sh:
```bash
gen_configs.sh <max stages> <max primitives per stage>
```

Then run any the desired tool(s), supplying --numstages and --nuprimitives arguments, e.g.,:
```bash
locs_reporter.py --numstages 3 --numprimitives 3
```

The phv\_reporter.py tool needs no arguments and does not need gen\_configs.sh to be run first; it looks at the HyPer4 configuration found in the hp4/p4src directory starting with hp4/p4src/hp4.p4.

The tern\_match\_reporter.py tool requires a --nano argument (path to nano log file to analyze) and optionally allows the user to change the ouput path of the .csv report (from the default results_ternmatch.csv) via --output, and -v or --verbose to show detailed output on stdout.
