% Location of the compressed data set
url = 'http://download.tensorflow.org/example_images/flower_photos.tgz';

% Store the output in a temporary folder
downloadFolder = tempdir;
filename = fullfile(downloadFolder,'flower_dataset.tgz');

% Uncompressed data set
imageFolder = fullfile(downloadFolder,'flower_photos');

if ~exist(imageFolder,'dir') % download only once
    disp('Downloading Flower Dataset (218 MB)...');
    websave(filename,url);
    untar(filename,downloadFolder)
end

flowerImageSet = imageDatastore(imageFolder,'LabelSource','foldernames','IncludeSubfolders',true);

% Total number of images in the data set
numel(flowerImageSet.Files)
% Display a one of the flower images
figure
I = imread(flowerImageSet.Files{3});
imshow(I);

type exampleBagOfFeaturesColorExtractor.m

doTraining = false;

if doTraining
    %Pick a random subset of the flower images
    trainingSet = splitEachLabel(flowerImageSet, 0.6, 'randomized');
    
    % Create a custom bag of features using the 'CustomExtractor' option
    colorBag = bagOfFeatures(trainingSet, ...
        'CustomExtractor', @exampleBagOfFeaturesColorExtractor, ...
        'VocabularySize', 5000);
else
    % Load a pretrained bagOfFeatures
    load('savedColorBagOfFeatures.mat','colorBag');
end

if doTraining
    % Create a search index
    flowerImageIndex = indexImages(flowerImageSet,colorBag,'SaveFeatureLocations',false);
else
    % Load a saved index
    load('savedColorBagOfFeatures.mat','flowerImageIndex');
end

% Define a query image
queryImage = readimage(flowerImageSet,15);

figure
imshow(queryImage)

% Search for the top 5 images with similar color content
[imageIDs, scores] = retrieveImages(queryImage, flowerImageIndex,'NumResults',5);


% Display results using montage. 
figure
montage(flowerImageSet.Files(imageIDs),'ThumbnailSize',[200 200])



