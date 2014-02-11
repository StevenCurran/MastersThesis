function [train_x, train_y, test_x, test_y] = GenerateTestData(people, nonPeople)

%Create an 80 20 split of the data.
TRAINING_PERCENTAGE = 0.95;
TESTING_PERCENTAGE = 0.05;


num_people_train = length(people) * TRAINING_PERCENTAGE;
num_non_people_train = length(nonPeople) * TRAINING_PERCENTAGE;

num_people_test = length(people) * TESTING_PERCENTAGE
num_non_people_test = length(nonPeople) * TESTING_PERCENTAGE;

people_train = people(:,:,1:num_people_train);
non_people_train = nonPeople(:,:,1:num_non_people_train);

%%need to generate the label vector in here... 
train_y = [];
for i = 1 : length(people_train)
    train_y = horzcat(train_y, [0 ; 1]);
end

for i = 1 : length(non_people_train)
    train_y = horzcat(train_y, [1 ; 0]);
end

train_x = cat(3, people_train, non_people_train);
shuffle = randperm(length(train_x));
%%shuffle the data, ensuring the labels are in the same order as the class
train_x = train_x(:,:,shuffle);
train_y = train_y(:,shuffle);


people_test = people(:,:,1:num_people_test);
non_people_test = nonPeople(:,:,1:num_non_people_test);

%%need to generate the label vector in here... 
test_y = [];
for i = 1 : length(people_test)
    test_y = horzcat(test_y, [0 ; 1]);
end

for i = 1 : length(non_people_test)
    test_y = horzcat(test_y, [1 ; 0]);
end

test_x = cat(3, people_test, non_people_test);
shuffle = randperm(length(test_x));
test_x = test_x(:,:,shuffle);
test_y = test_y(:,shuffle);



end

