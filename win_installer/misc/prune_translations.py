#!/usr/bin/env python

from __future__ import print_function

import os
import sys
import shutil


if __name__ == "__main__":
    ql_locale = sys.argv[1]
    main_locale = sys.argv[2]

    print("App locale:", ql_locale)
    print("Dist locale:", main_locale)

    assert os.path.exists(ql_locale)
    assert os.path.exists(main_locale)

    get_lang = lambda x: x.split("_")[0]

    # get a list of languages which QL has translations for
    ql_langs = set()
    for entry in os.listdir(ql_locale):
        ql_langs.add(get_lang(entry))

    # delete all gtk+ etc translations which QL doesn't support
    for entry in os.listdir(main_locale):
        entry_path = os.path.join(main_locale, entry)
        if get_lang(entry) not in ql_langs:
            print("Pruning", entry)
            shutil.rmtree(entry_path)
