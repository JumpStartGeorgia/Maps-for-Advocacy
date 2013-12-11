class CreatePlaceEvalAnswerObj < ActiveRecord::Migration
  def up
    PlaceEvaluationAnswer.transaction do 
      # drop old indexes
      remove_index :place_evaluations, :question_pairing_id
      remove_index :place_evaluations, :user_id
      remove_index :place_evaluations, :place_id

      # update the table name
      rename_table :place_evaluations, :place_evaluation_answers

      # add new column
      add_column :place_evaluation_answers, :place_evaluation_id, :integer

      # add indexes
      add_index :place_evaluation_answers, :question_pairing_id
      add_index :place_evaluation_answers, :place_evaluation_id

      # create the new table
      create_table :place_evaluations do |t|
        t.integer :place_id
        t.integer :user_id

        t.timestamps
      end

      PlaceEvaluationAnswer.reset_column_information
      PlaceEvaluation.reset_column_information

      # rename old colums
      rename_column :place_evaluation_answers, :user_id, :old_user_id
      rename_column :place_evaluation_answers, :place_id, :old_place_id
      
      # add indexes
      add_index :place_evaluations, :user_id
      add_index :place_evaluations, :place_id
      add_index :place_evaluations, :created_at

      PlaceEvaluationAnswer.reset_column_information
      PlaceEvaluation.reset_column_information
    
      # copy data to new table
      evaluations = PlaceEvaluationAnswer.order('created_at asc, old_user_id asc, question_pairing_id asc ')
      uniq_evals = evaluations.map{|x| [x.created_at, x.old_user_id, x.old_place_id]}.uniq
      uniq_evals.each do |uniq_eval|
        # create new eval record
        eval = PlaceEvaluation.create(:created_at => uniq_eval[0], :user_id => uniq_eval[1], :place_id => uniq_eval[2])
        
        # get all eval answers for this person/date
        answers = evaluations.select{|x| x.created_at == uniq_eval[0] && x.old_user_id == uniq_eval[1] && x.old_place_id == uniq_eval[2]}
        answers.each do |answer|
          answer.place_evaluation_id = eval.id
          answer.save
        end

      end      
    end    
  end

  def down
    PlaceEvaluation.transaction do 

      # make sure any new evaluations that have been added will exist in old table
      PlaceEvaluation.all.each do |eval|
        eval.place_evaluation_answers.each do |answer|
          answer.old_user_id = eval.user_id
          answer.old_place_id = eval.place_id
          answer.save        
        end
      end
      

      # drop indexes
      remove_index :place_evaluations, :user_id
      remove_index :place_evaluations, :place_id
      remove_index :place_evaluations, :created_at
      remove_index :place_evaluation_answers, :question_pairing_id
      remove_index :place_evaluation_answers, :place_evaluation_id

      # drop new table
      drop_table :place_evaluations

      # update the table name
      rename_table :place_evaluation_answers, :place_evaluations

      PlaceEvaluation.reset_column_information

      # drop new column
      remove_column :place_evaluations, :place_evaluation_id

      # rename old colums
      rename_column :place_evaluations, :old_user_id, :user_id
      rename_column :place_evaluations, :old_place_id, :place_id

      # add old indexes
      add_index :place_evaluations, :question_pairing_id
      add_index :place_evaluations, :user_id
      add_index :place_evaluations, :place_id

    end
  end
end
