#!/bin/bash

 rm -rf ./stylus_eval
 ~/tesseract/src/training/tesstrain.sh \
   --fonts_dir ~/.fonts \
   --lang eng --linedata_only \
   --noextract_font_properties \
   --langdata_dir ~/langdata_lstm \
   --tessdata_dir ~/tessdata_best \
   --exposures "0" \
   --save_box_tiff \
--distort_image \
   --fontlist "Stylus ITC Regular" "Stylus Light" "Stylus BT Light" \
   --training_text ./eng.stylus_eval.training_text \
   --workspace_dir ~/tmp \
   --output_dir ./stylus_eval

 rm -rf ./stylus
 ~/tesseract/src/training/tesstrain.sh \
   --fonts_dir ~/.fonts \
   --lang eng --linedata_only \
   --noextract_font_properties \
   --langdata_dir ~/langdata_lstm \
   --tessdata_dir ~/tessdata_best \
   --exposures "0" \
   --save_box_tiff \
--distort_image \
   --fontlist "Stylus ITC Regular" "Stylus Light" "Stylus BT Light" \
   --training_text ./eng.stylus.training_text \
   --workspace_dir ~/tmp \
   --output_dir ./stylus
 
 
 echo "/n ****** Finetune plus tessdata_best/eng model ***********"
 
 rm -rf  ./stylus_plus
 mkdir  ./stylus_plus
 
 combine_tessdata -e ~/tessdata_best/eng.traineddata \
   ~/tessdata_best/eng.lstm
  
lstmtraining \
  --model_output ./stylus_plus/stylus_plus \
  --traineddata ./stylus/eng/eng.traineddata \
  --continue_from ~/tessdata_best/eng.lstm \
  --old_traineddata ~/tessdata_best/eng.traineddata \
  --train_listfile ./stylus/eng.training_files.txt \
  --debug_interval -1 \
  --max_iterations 800
  
lstmtraining \
--stop_training \
  --traineddata ./stylus/eng/eng.traineddata \
  --continue_from ./stylus_plus/stylus_plus_checkpoint \
  --model_output ./stylus_plus/stylus.traineddata
  
cp ./stylus_plus/stylus.traineddata ./
  
time lstmeval \
  --model ./stylus_plus/stylus.traineddata \
  --eval_listfile  ./stylus_eval/eng.training_files.txt 
  
  lstmtraining \
--stop_training \
  --convert_to_int \
  --traineddata ./stylus/eng/eng.traineddata \
  --continue_from ./stylus_plus/stylus_plus_checkpoint \
  --model_output ./stylus_plus/stylus_int.traineddata
  
time lstmeval \
  --model ./stylus_plus/stylus_int.traineddata \
  --eval_listfile ./stylus_eval/eng.training_files.txt 

cp ./stylus_plus/stylus_int.traineddata ./


time lstmeval \
  --model ~/tessdata_best/eng.traineddata \
  --eval_listfile ./stylus_eval/eng.training_files.txt 
  