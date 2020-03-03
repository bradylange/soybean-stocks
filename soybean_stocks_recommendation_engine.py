# Developer: Brady Lange
# Date: 11/03/2019
# Description: MinneMUDAC Fall 2019 - farmer soybean stocks, Machine Learning
#              analysis with a recommendation engine.
# https://towardsdatascience.com/autoencoders-for-the-compression-of-stock-market-data-28e8c1a2da3e

# Import requires libraries
import pandas as pd
import xlrd
import numpy as np
import os
from keras.layers import Input, Dense
from keras.models import Model
from keras.callbacks import ModelCheckpoint, EarlyStopping
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler
from sklearn.metrics.pairwise import distance, linear_kernel
from sklearn.cluster import KMeans

# Load and Explore Data
# =============================================================================
# Load active contracts for March dataset
sbean_cont_mar = pd.read_excel(r"./data/active_soybean_contracts_for_march_2020.xlsx", sheet_name = "ZS_H_2020.CSV", skiprows = 3)
# Load active contracts for May dataset
sbean_cont_may = pd.read_excel(r"./data/active_soybean_contracts_for_may_2020.xlsx", sheet_name = "ZS_K_2020.CSV", skiprows = 3)
# Load active contracts for July dataset
sbean_cont_july = pd.read_excel(r"./data/active_soybean_contracts_for_july_2020.xlsx", sheet_name = "ZS_N_2020.CSV", skiprows = 3)

# Explore the dataset
print(sbean_cont_all.head())
print(sbean_cont_all.tail())
print(sbean_cont_all.describe())
print(sbean_cont_all.shape)
print(sbean_cont_all.size)
print(len(sbean_cont_all))
print(sbean_cont_all.columns)
print("\nNull Values:\n" + str(sbean_cont_all.isnull().sum()))

# Preprocess Data
# =============================================================================
# sbean_cont_id = sbean_cont_all[["Date"]]
# sbean_cont_all.drop(sbean_cont_id.columns, inplace = True, axis = 1)

sbean_cont_all = [sbean_cont_mar, sbean_cont_may, sbean_cont_july]
sbean_cont_all = pd.concat(sbean_cont_all)
sbean_cont_all.sort_values(by = "Date", inplace = True)

sbean_cont_all.insert(0, "Year", sbean_cont_all["Date"].dt.year)
sbean_cont_all.insert(1, "Month", sbean_cont_all["Date"].dt.month)
sbean_cont_all.insert(2, "Day", sbean_cont_all["Date"].dt.day)
sbean_cont_all.insert(3, "Avg_Price", 
                      (sbean_cont_all["Open"] + sbean_cont_all["High"] 
                      + sbean_cont_all["Low"] + sbean_cont_all["Close"]) 
                      / sbean_cont_all[["Open", "High", "Low", "Close"]].shape[1])
sbean_cont_all.drop(["Date", "Open", "High", "Low", "Close"], axis = 1, inplace = True)

sbean_cont_all[["Year", "Month", "Day"]] = sbean_cont_all[["Year", "Month", "Day"]].astype(str)
# imputerNum = SimpleImputer(missing_values = np.nan, strategy = "mean")
# imputerNum.fit(beers[["abv", "ibu"]])
# beers[["abv", "ibu"]] = imputerNum.transform(beers[["abv", "ibu"]])
# imputerCat = SimpleImputer(missing_values = np.nan, strategy = "constant",
#                            fill_value = "null")
# imputerCat.fit(beers["style"].values.reshape(-1, 1))
# beers["style"] = imputerCat.transform(beers["style"].values.reshape(-1, 1))
# print("\nNull Values:\n" + str(beers.isnull().sum()))
# 
# std = StandardScaler()
# beers[["abv", "ibu", "ounces"]] = std.fit_transform(beers[["abv", "ibu", "ounces"]])

print(sbean_cont_all.corr())
# One Hot Encode, drop first encoded column to prevent multicollinearity
sbean_cont_all = pd.get_dummies(sbean_cont_all, drop_first = True)

# 80% training data, 20% validation data
split = np.random.rand(len(sbean_cont_all)) < 0.8
# Instantiate training data
train = sbean_cont_all[split]
# Instantiate validation data
validate = sbean_cont_all[~split]

# Autoencoder - Dimensionality Reduction
# =============================================================================
input_dim = sbean_cont_all.shape[1]
encoding_dim = 9

input_layer = Input(shape = (input_dim, ), name = "input_layer")
# Encoder layers
encoded = Dense(encoding_dim, activation = "relu", name = "encoded_hl_1")(input_layer)
# Decoder layers
decoded = Dense(input_dim, activation = "sigmoid", name = "output_layer")(encoded)

# Instantiate Autoencoder model
autoencoder = Model(input_layer, decoded)

# Instantiate encoder model
encoder = Model(input_layer, encoded)

# Instantiate decoder model
# Create a placeholder for an encoded input
encoded_input = Input(shape = (encoding_dim, ))
# Retrieve the last layer of the autoencoder model
decoder_layer = autoencoder.layers[-1]
# create the decoder model
decoder = Model(encoded_input, decoder_layer(encoded_input))

# Configure Autoencoder model
autoencoder.compile(optimizer = "adam", loss = "binary_crossentropy",
                    metrics = ["accuracy"])

mod_check = ModelCheckpoint(r".\data\models\checkpoints\weights_{epoch:02d}_{val_loss:.2f}.hdf5",
                           mode = "min")
early_stop = EarlyStopping(monitor = "val_loss", patience = 2)
# Train Autoencoder model
autoencoder.fit(train, train,
                epochs = 100,
                batch_size = 128,
                shuffle = True,
                validation_data = [validate, validate],
                callbacks = [mod_check, early_stop])

# Encode/Decode Data
# =============================================================================
encodedValidate = encoder.predict(validate)
decodedValidate = pd.DataFrame(decoder.predict(encodedValidate))
decodedValidate.columns = validate.columns
print("Original Dataset:\n", validate)
print("Reconstructed Dataset:\n", decodedValidate)

# K-Means Clustering
# =============================================================================
km = KMeans(n_clusters = 3)
km.fit(validate)
km.predict(validate)

def getEuclideanDistance(centroids, inputRow):
    # Euclidean Distance
    return distance.euclidean(centroids, inputRow)
def getCosineSimilarity(centroids, inputRow):
    # Cosine Similarity
    return distance.cosine(centroids, inputRow)
def getClustersDistances(centroids, numClusters, inputRow):
    simMat = {}
    for i in range(0, numClusters):
        simMatRow = getEuclideanDistance(centroids[i], inputRow)
        simMat.update({"Cluster " + str(i): simMatRow})
    return simMat

simMat = np.zeros([validate.shape[0], 3])
for i in range(0, validate.shape[0]):
    euclDist = getClustersDistances(km.cluster_centers_, 3, validate[i])
    euclDist = list(euclDist.values())
    simMat[i] = euclDist
print(simMat)

# Recommendation Engine
# =============================================================================
# Calculate Cosine Similarity
cosineSimilarity = linear_kernel(simMat, simMat)

# TODO:
sbean_cont_all_orig = train.append(sbean_cont_id)
print(sbean_cont_all_orig)
exit(0)
indices = pd.Series(sbean_cont_all_orig["Date"].index)

def recommend(index, cosineSim = cosineSimilarity):
    id = indices[index]
    # Retrieve pairwise similarity scores of all beers compared to that beer
    similarityScores = list(enumerate(cosineSim[id]))
    similarityScores = sorted(similarityScores, key = lambda x: x[1], reverse = True)
    # Display top 10 beers most similar to input beer
    similarityScores = similarityScores[1:11]
    # Get beers index
    dateIndex = [i[0] for i in similarityScores]
    # Return top 10 most similar beers
    return sbean_cont_all_orig["Date"].iloc[dateIndex]

print(recommend(0))
