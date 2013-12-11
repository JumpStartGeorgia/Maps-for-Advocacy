class UpdateAnswers < ActiveRecord::Migration
  def up
    PlaceEvaluation.transaction do
      PlaceEvaluation.where('answer > 0').each do |eval|
        eval.answer += 1
        eval.save
      end
    end
  end

  def down
    PlaceEvaluation.transaction do
      PlaceEvaluation.where('answer > 0').each do |eval|
        eval.answer -= 1
        eval.save
      end
    end
  end
end
