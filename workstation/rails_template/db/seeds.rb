# [OPTIMIZE] Create a module or class to be able to include this:
# include FactoryBot::Syntax::Methods
6.times do
  FactoryBot.create :organization
  Faker::UniqueGenerator.clear
end
