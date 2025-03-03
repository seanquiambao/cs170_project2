function formatted_cell = format_cell(cell)
num_cell = num2cell(cell);
formatted_cell =['{' strjoin(cellfun(@num2str, num_cell, 'UniformOutput', false), ', ') '}'];
end

function accuracy= leave_one_out_cross_validation(data, current_set,feature_to_add)
observe_features = [current_set, feature_to_add];
copy_data = data;

for j = 1 : size(copy_data, 1)
    if ~ismember(observe_features, j)
        copy_data(:, j + 1) = 0;
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
disp(['Beginning Search Algorithm'])

end
function feature_search_forward(data)
disp(['Beginning Search Algorithm'])

current_set_of_features = [];

best_feature = [];
best_accuracy = 0;

for i = 1 : size(data, 2) - 1
    disp(['On the ', num2str(i), 'th level of the search tree'])
    feature_to_add_at_this_level = [];
    best_so_far_accuracy = 0;



    for k = 1 : size(data, 2) - 1
        if isempty(intersect(current_set_of_features, k))



            accuracy = leave_one_out_cross_validation(data, current_set_of_features, k + 1);
            formatted_cell = format_cell([current_set_of_features, k]);
            disp(['Considering features ', formatted_cell, ' with accuracy of ', num2str(accuracy)])

            if accuracy > best_so_far_accuracy
                best_so_far_accuracy = accuracy;
                feature_to_add_at_this_level = k;
            end
        end
    end

    current_set_of_features(i) = feature_to_add_at_this_level;

    formatted_cell = format_cell(current_set_of_features);
    disp(['Feature Set ', formatted_cell, ' was best, accuracy of ', num2str(best_so_far_accuracy)]);

    if best_so_far_accuracy > best_accuracy
        best_feature = current_set_of_features;
        best_accuracy = best_so_far_accuracy;
    end


end
formatted_cell = format_cell(best_feature);
disp(['Finished Search!! The best subset is ', formatted_cell, ' with an accuracy of ', num2str(best_accuracy)]);
end

function main(data)
disp(['Type the number of algorithm you want to run:'])
disp(['1. Forward Selection'])
disp(['2. Backward Elimination'])

prompt = input("Enter a number:");


if prompt == 1
    feature_search_forward(data)
else
    feature_search_backward(data)
end

end
data = load("CS170_Small_Data__83.txt");

main(data)