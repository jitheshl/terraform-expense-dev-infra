#!/bin/bash

for i in *; do

    if [ ! -d "$i" ] || [ "$i" == ".git" ]; then
        continue
    fi

    echo "========== APPLYING $i =========="

    cd "$i" || exit 1

    terraform init

    if [ $? -ne 0 ]; then
        echo "========== $i INIT FAILED =========="
        exit 1
    fi

    terraform plan

    if [ $? -ne 0 ]; then
        echo "========== $i PLAN FAILED =========="
        exit 1
    fi

    terraform apply -auto-approve

    if [ $? -ne 0 ]; then
        echo "========== $i APPLY FAILED =========="
        exit 1
    fi

    echo "========== $i APPLIED SUCCESSFULLY =========="

    cd ..
done

echo "========================================"
echo "       APPLY COMPLETE"
echo "========================================"