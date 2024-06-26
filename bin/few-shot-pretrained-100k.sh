#!/bin/bash
allow_skip_exp=False
eval_before_training=True
balanced_ibc=True

train_batch_size=1
grad_accum_factor=1

lr=0.003
re='^[0-9]+$'

cuda_device=3

# Set adaptively
num_steps=0
eval_epoch_interval=0

for model in 't03b' # 't011b'
do
  # For zero-shot set to '0', for all to 'all' 4 8 16 32 64 128 256 512
  for num_shot in 512
  do
    # Datasets: car, income, heart, diabetes, jungle, bank, blood, calhousing, creditg, jungle
    # Run all serializations for car
    for dataset in limph
    do
      # Zero-shot
      # eval_before_training=True
      # num_steps=0
      # Few-shot
      eval_before_training=False
      # num_steps=$(( 30 * ($num_shot / $train_batch_size)))
      num_steps=10241
      eval_epoch_interval=5

      # For all run
      if ! [[ $num_shot =~ $re ]]; then
        if [[ $dataset = *"income"* ]]; then
          num_steps=295000
        fi
        if [[ $dataset = *"car"* ]]; then
          num_steps=10500
        fi
        if [[ $dataset = *"heart"* ]]; then
          num_steps=5600
        fi
        if [[ $dataset = *"diabetes"* ]]; then
          num_steps=4700
        fi
        if [[ $dataset = *"bank"* ]]; then
          num_steps=272000
        fi
        if [[ $dataset = *"blood"* ]]; then
          num_steps=4520
        fi
        if [[ $dataset = *"calhousing"* ]]; then
          num_steps=124000
        fi
        if [[ $dataset = *"creditg"* ]]; then
          num_steps=6000
        fi
        if [[ $dataset = *"jungle"* ]]; then
          num_steps=270000
        fi
        if [[ $dataset = *"limph"* ]]; then
          echo "Hello world================="
          num_steps=20
        fi
      fi

      for seed in 42
      do
        CUDA_VISIBLE_DEVICES=${cuda_device} CONFIG_PATH=configs HF_HOME=/root/.cache/huggingface \
        python -m src.pl_train -c ${model}.json+ia3.json+global.json -k dataset=${dataset} load_weight="pretrained_checkpoints/${model}_ia3_finish.pt" num_steps=${num_steps} num_shot=${num_shot} \
        exp_name=${model}_${dataset}_numshot${num_shot}_seed${seed}_ia3_pretrained100k few_shot_random_seed=${seed} seed=${seed} allow_skip_exp=${allow_skip_exp} eval_before_training=${eval_before_training} eval_epoch_interval=${eval_epoch_interval} \
        batch_size=${train_batch_size} grad_accum_factor=${grad_accum_factor} lr=${lr}
      done
    done
  done
done