function formatted_cell = format_cell(cell)
num_cell = num2cell(cell);
formatted_cell =['{' strjoin(cellfun(@num2str, num_cell, 'UniformOutput', false), ', ') '}'];
end

function accuracy= leave_one_out_cross_validation(data, current_set, feature_to_add, algorithm)

copy_data = data;

if algorithm == "forward"
    observe_features = [current_set, feature_to_add];
    % formatted_cell = format_cell(observe_features);
    % display(["Forward set: ", formatted_cell]);
    for j = 1 : size(copy_data, 1)
        if ~ismember(observe_features, j)
            copy_data(:, j + 1) = 0;
        end
    end
else
    % formatted_cell = format_cell(current_set);
    % display(["Backward set: ", formatted_cell]);
    for j = 1 : size(copy_data, 1)
        if ~ismember(current_set, j)
            copy_data(:, j + 1) = 0;
        end
    end
end


number_correctly_classified = 0;

for i = 1 : size(copy_data, 1)
    object_to_classify = copy_data(i, 2:end);
    label_object_to_classify = copy_data(i, 1);

    nearest_neighbor_distance = inf;
    nearest_neighbor_location = inf;
    for k = 1 : size(copy_data, 1)
        if k ~= i
            distance = sqrt(sum((object_to_classify - copy_data(k, 2:end)).^2));
            if distance < nearest_neighbor_distance
                nearest_neighbor_distance = distance;
                nearest_neighbor_location = k;
                nearest_neighbor_label = copy_data(nearest_neighbor_location, 1);
            end

        end
    end

    if label_object_to_classify == nearest_neighbor_label
        number_correctly_classified = number_correctly_classified + 1;
    end
end
accuracy = number_correctly_classified / size(copy_data, 1);

end



function feature_search_backward(data)
disp(['Beginning Search.'])


current_set_of_features = 1:size(data,2) - 1;

best_feature = [];
best_accuracy = 0;
for i = 1 : size(data, 2) - 1
    feature_to_remove_at_this_level = 0;
    best_so_far_accuracy = 0;
    best_feature_set = [];


    disp([' '])

    for k = 1 : size(data, 2) - 1
        
        if ~isempty(intersect(current_set_of_features, k))
            index = (current_set_of_features == k);
            current_copy = current_set_of_features;
            current_copy(index) = [];
            accuracy = leave_one_out_cross_validation(data, current_copy, k, 'backwards');
            formatted_cell = format_cell(current_copy);
            disp(['     Using feature(s) ', formatted_cell, ' accuracy is ', num2str(accuracy * 100), '%'])

            if accuracy > best_so_far_accuracy
                best_so_far_accuracy = accuracy;
                feature_to_remove_at_this_level = k;
                best_feature_set = formatted_cell;
            end

            if accuracy > best_accuracy
                best_feature = current_copy;
                best_accuracy = accuracy;
            end
        end
    end

    index = (current_set_of_features == feature_to_remove_at_this_level);
    current_set_of_features(index) = [];
    disp([' '])
    disp(['Feature set ', best_feature_set, ' was the best, accuracy is ', num2str(best_so_far_accuracy * 100), '%']);
end
formatted_cell = format_cell(best_feature);
disp([' '])
disp(['Finished Search!! The best subset is ', formatted_cell, ', which has an accuracy of ', num2str(best_accuracy * 100), '%']);
end




function feature_search_forward(data)
disp(['Beginning Search.'])

current_set_of_features = [];

best_feature = [];
best_accuracy = 0;

for i = 1 : size(data, 2) - 1
    feature_to_add_at_this_level = [];
    best_so_far_accuracy = 0;

    disp(' ')
    for k = 1 : size(data, 2) - 1
        if isempty(intersect(current_set_of_features, k))
            accuracy = leave_one_out_cross_validation(data, current_set_of_features, k, "forward");
            formatted_cell = format_cell([current_set_of_features, k]);
            disp(['     Using feature(s) ', formatted_cell, ' accuracy is ', num2str(accuracy * 100), '%'])

            if accuracy > best_so_far_accuracy
                best_so_far_accuracy = accuracy;
                feature_to_add_at_this_level = k;
            end
        end
    end

    disp(' ')
    
    if best_so_far_accuracy > best_accuracy
        best_feature = current_set_of_features;
        best_accuracy = best_so_far_accuracy;
    else
        disp(['(Warning, Accuracy has decreased! Continuing search in case of local maxima)'])
    end
    current_set_of_features(i) = feature_to_add_at_this_level;
    formatted_cell = format_cell(current_set_of_features);
    disp(['Feature Set ', formatted_cell, ' was best, accuracy is ', num2str(best_so_far_accuracy * 100), '%']);




end
formatted_cell = format_cell(best_feature);
disp([' '])
disp(['Finished Search!! The best subset is ', formatted_cell, ', which has an accuracy of ', num2str(best_accuracy * 100), '%']);
end

function main()
disp(['Welcome to Sean Quiambaos Feature Selection Algorithm'])
input_data = input("Type the data you want to run: ");
data = load(input_data);
disp([' '])
disp(['Type the number of algorithm you want to run:'])
disp(['1. Forward Selection'])
disp(['2. Backward Elimination'])

prompt = input("");

number_of_features = size(data, 2) - 1;
full_accuracy = leave_one_out_cross_validation(data, 1:size(data,2) - 1, 0, "forward");

disp([' '])

disp(['This dataset has ', num2str(number_of_features), ' features (not including class attribute), with ', num2str(size(data, 1)), ' instances.'])

disp([' '])

disp(['Running nearest neighbor with all 4 features, using "leave-one-out" evaluation, I get an accuracy of ', num2str(full_accuracy * 100), '%'])
disp([' '])
if prompt == 1
    feature_search_forward(data)
else
    feature_search_backward(data)
end

end

main()