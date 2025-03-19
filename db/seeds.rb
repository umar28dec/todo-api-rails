5.times do |i|
  Todo.create!(
    title: "Task #{i + 1}",
    description: "Description for task #{i + 1}",
    completed: [true, false].sample
  )
end