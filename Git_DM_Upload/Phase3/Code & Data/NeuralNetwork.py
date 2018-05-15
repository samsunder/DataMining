
# coding: utf-8

# In[1]:


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
# %inl


# In[2]:


num_classes = 10
users = [1,5,11,16,19,20,22,24,28,36]
np.random.seed(1)


# In[3]:


filenames = []
for user in users:
    filenames.append('User'+str(user)+'.csv')
# filename


# In[4]:


# model.reset_states()
def define_model(input_size):
    model = Sequential()
    model.add(Dense(512, activation='sigmoid', input_shape=(x_train.shape[1],)))
    model.add(Dense(512, activation='sigmoid'))
    model.add(Dense(num_classes, activation='softmax'))
    
#     model.summary()
    return model


# In[24]:


def confurion_metrics_score(CFM):
    
    r = np.zeros(CFM.shape[1])
#     print(CFM.shape[1])
    p = np.zeros(CFM.shape[1])
    a = np.zeros(CFM.shape[1])
    f = np.zeros(CFM.shape[1])
#     excel_mat = np.zeros((10,4))
    for i in range(CFM.shape[1]):
        r[i] =CFM[i,i]/sum(CFM[i,:]); #finding recall for every class
        p[i] =CFM[i,i]/sum(CFM[:,i]); #finding precision for every class
        a[i] =np.matrix.trace(CFM)*100/(np.matrix.trace(CFM)-(2*CFM[i,i])+sum(CFM[i,:])+sum(CFM[:,i])); #finding accuracy for every class
        
        r[np.isnan(r)] =1; 
        p[np.isnan(p)] =1; 
        f[np.isnan(f)] =1; 
#         p(isnan(p))=[];
#         a(isnan(a))=[];
#         f(isnan(f))=[];
# #         removing NaN
        f[i] =2*r[i]*p[i]/(p[i]+r[i]);#finding f value for every class 
    
#     excel_mat = np.vstack 
    print('{}'.format(file))
    print('Gesture |Accuracy  |Precision |Recall |F1 Score')
    for i in range(len(p)):
        print('{}:       {:{}f}%    |{:{}f}      |{:{}f}   |{:{}f}'.format(i+1,a[i], 0.2,p[i],.2,r[i],.2,f[i],.2 ))  

 


# In[25]:


np.random.seed(2)
for file in filenames: 
    training_data = pd.read_csv('./UserData/'+str(file), header=None) #"User1.csv"

    x_data = training_data.as_matrix() 

    np.random.shuffle(x_data)
    x_train = x_data[:(int(0.6*x_data.shape[0])),0:x_data.shape[1]-1]
    x_test = x_data[(int(0.6*x_data.shape[0])):,0:x_data.shape[1]-1]

    y_train = np.array((x_data[:(int(0.6*x_data.shape[0])),-1] - 1), dtype=int)
    y_test = np.array((x_data[(int(0.6*x_data.shape[0])):,-1] - 1), dtype= int) 

    y_train_one_hot = np.eye(num_classes)[y_train]
    y_test_one_hot = np.eye(num_classes)[y_test]
    
    
    model = define_model(x_train.shape[1])
    model.compile(loss='categorical_crossentropy',
              optimizer=RMSprop(),
              metrics=['accuracy'])#, precision, recall, f1_score])
    
    history = model.fit(x_train, y_train_one_hot, 
                    epochs=100,
                    verbose=0,
                    validation_data=(x_test, y_test_one_hot)) 
    y_pred = model.predict(x_test)
    y_pred = (y_pred > 0.5)
    CMF = confusion_matrix(y_test_one_hot.argmax(axis=1), y_pred.argmax(axis=1))
    confurion_metrics_score(CMF)   
    
    plt.plot(history.history['acc'])
    plt.plot(history.history['val_acc'])
    plt.title('model accuracy')
    plt.ylabel('accuracy')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper left')
    save_file = str(file)+'.jpg'
    plt.savefig(save_file)
    plt.show()
    print("---------------------------------------------------\n") 

