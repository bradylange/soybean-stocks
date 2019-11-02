import pandas as pd
import keras
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import RobustScaler

path = "/home/ubuntu/Documents/MUDAC/Fall_2019/soybean-stocks/"

march = pd.read_csv(path+"Modified Data/march_clean.csv")
may = pd.read_csv(path+"Modified Data/may_clean.csv")
july = pd.read_csv(path+"Modified Data/july_clean.csv")

# Available Vars : year, month, day, close_lag, close_prev_year
feature_vars = ['year', 'month', 'close_lag', 'close_prev_year']
label_var = ['close']
X = march[feature_vars].values
Y = march[label_var].values

# Scale Data
feature_scaler = RobustScaler()
X_scaled = feature_scaler.fit_transform(X)
label_scaler = RobustScaler()
Y_scaled = label_scaler.fit_transform(Y)

Xtrain, Xtest, Ytrain, Ytest = train_test_split(X_scaled, Y_scaled, test_size=.1)

epochs = 1000
neurons = 64
dropout = .1
activation = 'relu'
learning_rate = 0.001

# keras.activations.

my_simple_ann = keras.models.Sequential()
my_simple_ann.add(keras.layers.Dense(neurons, input_shape=(Xtrain.shape[1],)))
my_simple_ann.add(keras.layers.BatchNormalization())
my_simple_ann.add(keras.layers.Dropout(dropout))
my_simple_ann.add(keras.layers.Activation(activation))
my_simple_ann.add(keras.layers.Dense(round(neurons/2)))
my_simple_ann.add(keras.layers.BatchNormalization())
my_simple_ann.add(keras.layers.Dropout(dropout))
my_simple_ann.add(keras.layers.Activation(activation))
my_simple_ann.add(keras.layers.Dense(round(neurons/4)))
my_simple_ann.add(keras.layers.BatchNormalization())
my_simple_ann.add(keras.layers.Dropout(dropout))
my_simple_ann.add(keras.layers.Activation(activation))
my_simple_ann.add(keras.layers.Dense(1))
my_simple_ann.compile(optimizer=keras.optimizers.Adam(lr=learning_rate), loss=keras.losses.mean_squared_error, metrics=['accuracy'])

my_simple_ann.fit(Xtrain, Ytrain, epochs=epochs, verbose=1)

print("Predictions:\n", label_scaler.inverse_transform(my_simple_ann.predict(Xtest)))
print("Actual:\n", label_scaler.inverse_transform(Ytest))