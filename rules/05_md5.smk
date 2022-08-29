
rule md5_check:
    input:
        row_wise('data/{file}', sample_files)
    output:
        'analysis/observed-checksum.txt',
        'analysis/differing-checksum.txt'
    log:
        'logs/mdf5-check.txt'
    shell:
        """
        md5sum data/*fastq.gz > analysis/observed-checksum.txt

        # compare the expected checksum ###########
        diff                                      \
        <(                                        \
            cat checksum.txt                    | \
            `# with only single white space`      \
            sed 's,[ \t]\+, ,g'                 | \
            `# and no leading/trailing space`     \
            sed 's,[ \t]*$,,'                   | \
            sed 's,^[ \t]*,,'                   | \
            `# ensure same order in both files`   \
            sort                                  \
        )                                         \
        `# against the observed values`           \
        <(                                        \
            cat analysis/observed-checksum.txt  | \
            `# files without dir prefix `         \
            sed 's,data/,,g'                    | \
            `# with only single white space`      \
            sed 's,[ \t]\+, ,g'                 | \
            `# and no leading/trailing space`     \
            sed 's,[ \t]*$,,'                   | \
            sed 's,^[ \t]*,,'                   | \
            `# ensure same order in both files`   \
            sort                                  \
        )                                         \
        > analysis/differing-checksum.txt  || true
        ###########################################

        if [[ -s 'analysis/differing-checksum.txt' ]] ; then
            echo 'Error: Checksums differ, double check for correctness' >> {log}
            cat 'analysis/differing-checksum.txt' >> {log}
        else
            echo 'All checksums seem good' >> {log}
        fi
        """

tasks.append('analysis/differing-checksum.txt')
