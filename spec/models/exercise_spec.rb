require 'rails_helper'

RSpec.describe Exercise, type: :model do
  let(:current_user) { FactoryBot.create(:user) }
  let(:question) { FactoryBot.create(:question) }
  let(:exercise) { FactoryBot.create(:exercise, user: current_user, questions: [question]) }

  describe 'Validation - Basic Setup of Testing' do
    it 'has a valid factory' do
      expect(exercise).to be_valid
    end

    it 'is valid given a string for a title and creates a model object with general description and user attributes' do
      exercise = Exercise.new(
        title: 'Senecas Dance with Dragons',
        general_description: 'An amazing exercise to really get your pants off.',
        user: current_user,
        questions: [question]
      )

      expect(exercise).to be_valid
    end
  end

  describe 'Attributes - Classic ActiveRecord Instance Methods' do
    it 'returns a title' do
      exercise = FactoryBot.create(:exercise, title: 'Senecas Courage Walk', questions: [question])
      expect(exercise.title).to eq('Senecas Courage Walk')
    end

    it 'returns a general description' do
      exercise = FactoryBot.create(:exercise, general_description: 'Take a stroll with Seneca and beef up your courage.', questions: [question])
      expect(exercise.general_description).to eq('Take a stroll with Seneca and beef up your courage.')
    end

    it 'returns a global boolean' do
      exercise = FactoryBot.create(:exercise, global: false, questions: [question])
      expect(exercise.global?).to eq(false)
    end

    it 'can access the associated image icon attributes via active storage' do
      exercise = FactoryBot.create(:exercise, :with_icon, questions: [question])
      filename_hash = exercise.icon.filename.instance_values
      actual_filename_as_array = filename_hash.values
      expect(filename_hash).to include('filename')
      expect(actual_filename_as_array).to include('test-image.jpg')
    end
  end

  # Henry's custom methods
  describe '#rehearsals_for_user' do
    it 'successfully fetches all rehearsals for that particular exercise for that particular user' do
      user = FactoryBot.create(:user)
      question = FactoryBot.create(:question)
      exercise = FactoryBot.create(:exercise, :socrates_tag, questions: [question])
      rehearsal = FactoryBot.create(:rehearsal, exercise:, user:)

      actual = exercise.rehearsals_for_user(user)

      expected = [rehearsal]
      expect(actual).to eq(expected)
    end

    it 'does not fetch other users rehearsals' do
      user = FactoryBot.build_stubbed(:user)
      user_two = FactoryBot.build_stubbed(:user)
      question = FactoryBot.create(:question)
      exercise = FactoryBot.create(:exercise, questions: [question])
      rehearsal = FactoryBot.create(:rehearsal, exercise:, user: user_two)

      actual = exercise.rehearsals_for_user(user)

      expect(actual).to_not include(rehearsal)
    end
  end

  describe '#self.tagged_with (find EXERCISE with this tag)' do
    it 'returns an exercise when given a tag associated with it' do
      FactoryBot.create(:exercise, :heraklitus_tag, title: 'Courageous Seneca', questions: [question])
      expect(Exercise.tagged_with('Heraklitus').first.title).to eq('Courageous Seneca')
    end
  end

  describe '#tag_list (getter - find TAGS linked to this exercise)' do
    it 'returns an exercise when given a tag associated with it' do
      exercise = FactoryBot.create(:exercise, :aristotle_tag, questions: [question])
      expect(exercise.tag_list).to include('Aristotle')
    end
  end

  describe '#tag_list= (setter)' do
    it 'sets a tag' do
      exercise.tag_list = 'Aristarchus'
      expect(exercise.tag_list).to include('Aristarchus')
    end
  end

  describe '#maximum_number_of_questions' do
    it 'validates to prevent more than 7 questions' do
      exercise = Exercise.new(
        title: 'Senecas Dance with Dragons',
        general_description: 'An amazing exercise to really get your pants off.',
        user: current_user,
        questions: [question]
      )

      8.times { exercise.questions.build(inquiry: 'Why?') }

      exercise.valid?
      expect(exercise.errors[:base]).to include('You may only add a max of 7 questions.')
    end
  end
end
