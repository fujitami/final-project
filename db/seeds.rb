list__tag = ['happy', 'anger', 'sad', 'surprise', 'fear', 'disgust', 'neutral']
list__color = ['orange', 'red', 'indigo', 'yellow', 'purple', 'gray', 'white']

lists = list__tag.zip(list__color)

lists.each do |tag, color|
  ActsAsTaggableOn::Tag.new(name: tag, color: color).save
end
