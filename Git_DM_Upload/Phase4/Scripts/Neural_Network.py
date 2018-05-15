import pandas as pd
import numpy as np
from keras.models import Sequential
from keras.layers import Dense
from keras.optimizers import RMSprop
from keras import utils
from keras import backend as K
from keras.utils import plot_model 
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix 
import pandas as pd
import seaborn as sns


global_p=[]
global_r=[]
global_f=[]
global_a=[]
num_classes = 10
test_users = [14,15,18,21,23,25,26,27,29,30,31,32,33,34,35,37] #3#8 17 #2,4,6,7,9,10,12,13,
np.random.seed(1)

filenames = []
for user in test_users:
    filenames.append('User'+str(user)+'.csv')

def define_model(input_size):
    model = Sequential()
    model.add(Dense(512, activation='sigmoid', input_shape=(x_train.shape[1],)))
    model.add(Dense(512, activation='sigmoid'))
    model.add(Dense(num_classes, activation='softmax'))
    return model

def confurion_metrics_score(CFM,file,true_label,predicted_label):
    gestures = np.arange(1,CFM.shape[1]+1)
    r = np.zeros(CFM.shape[1])
    p = np.zeros(CFM.shape[1])
    a = np.zeros(CFM.shape[1])
    f = np.zeros(CFM.shape[1])
    for i in range(CFM.shape[1]):
        if i in true_label:

            r[i] =CFM[i,i]/sum(CFM[i,:]) #finding recall for every class
            p[i] =CFM[i,i]/sum(CFM[:,i]) #finding precision for every class
            a[i] =np.matrix.trace(CFM)*100/(np.matrix.trace(CFM)-(2*CFM[i,i])+sum(CFM[i,:])+sum(CFM[:,i])); #finding accuracy for every class
            f[i] =2*r[i]*p[i]/(p[i]+r[i]);#finding f value for every class 

            if CFM[i,i] == 0:
                if (sum(CFM[i,:])  - CFM[i,i] == 0) or (sum(CFM[i,:]) - CFM[i,i] == 0):
                    r[i] =1
                    p[i] =1 
                    f[i] =1
                if (sum(CFM[i,:]) - CFM[i,i] > 0) and (sum(CFM[i,:]) - CFM[i,i] > 0):
                    r[i] =0 
                    p[i] =0 
                    f[i] =0
            
    global global_p,global_f,global_r,global_a
    
    global_p = global_p+[file]+list(p)
    global_r = global_r+[file]+list(r)
    global_f = global_f+[file]+list(f)
    global_a = global_a+[file]+list(a)
    
    metrics = pd.DataFrame({'1Class':gestures,'2Precision': p, '3Recall': r, '4F1 Score': f,'5Accuracy':a})

    metrics.to_csv(file[4:6]+'.csv',index=None)

    print('Gesture |Accuracy  |Precision |Recall |F1 Score')
    for i in range(len(p)):
        print('{}:       {:{}f}%    |{:{}f}      |{:{}f}   |{:{}f}'.format(i+1,a[i], 0.2,p[i],.2,r[i],.2,f[i],.2 ))  


        
training_data = pd.read_csv('./data/'+'TrainData.csv', header=None) #"User1.csv"

x_data = training_data.as_matrix() 
np.random.shuffle(x_data)
x_train = x_data[:,0:x_data.shape[1]-1] 


y_train = np.array((x_data[:,-1] - 1), dtype=int) 


y_train_one_hot = np.eye(num_classes)[y_train]

model = define_model(x_train.shape[1])
model.compile(loss='categorical_crossentropy',
          optimizer=RMSprop(),
          metrics=['accuracy'])#, precision, recall, f1_score])


for file in filenames: 
    test_data = pd.read_csv('./data/testData/'+str(file), header=None) #"User1.csv"

    x_data = test_data.as_matrix() 
    print(file,x_data.shape)
     
    x_test = x_data[:,0:x_data.shape[1]-1]
 
    y_test = np.array((x_data[:,-1] - 1), dtype= int) 
 
    y_test_one_hot = np.eye(num_classes)[y_test]
    
     
    
    history = model.fit(x_train, y_train_one_hot, 
                    epochs=100,
                    verbose=0,
                    validation_data=(x_test, y_test_one_hot)) 
    y_pred = model.predict(x_test)
    y_pred = (y_pred > 0.5)
    
    true_class_labels = y_test_one_hot.argmax(axis=1)
    prediced_class_label = y_pred.argmax(axis=1)
    
    CMF = confusion_matrix(y_test_one_hot.argmax(axis=1), y_pred.argmax(axis=1))
    confurion_metrics_score(CMF,file,true_class_labels,prediced_class_label)   
    
    print("---------------------------------------------------\n") 


