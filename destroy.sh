#!/bin/bash

for i in $(printf '%s\n' */ | sort -r); do

    if [[ "$i" == "terraform.tfstate" || "$i" == "README.md" ]]; then
        continue
    fi

    if [ ! -d "$i" ]; then
        continue
    fi

    echo "========== DESTROYING $i =========="

    cd "$i" || exit 1

    terraform destroy -auto-approve

    if [ $? -ne 0 ]; then
        echo "========== $i DESTROY FAILED =========="
        exit 1
    fi

    echo "========== $i DESTROYED SUCCESSFULLY =========="

    cd ..
done

echo "========================================"
echo "       DESTROY COMPLETE"
echo "========================================"