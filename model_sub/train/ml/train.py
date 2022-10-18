# %%
import pandas as pd
import sqlalchemy

from sklearn import model_selection
from sklearn import ensemble

from sklearn import pipeline
from sklearn import metrics

from feature_engine import imputation
from feature_engine import encoding

def report_model(X, y, model, metric, is_prob=True):
    if is_prob:
        y_pred = model.predict_proba(X)[:,1]
    else:
        y_pred = model.predict(X)
    res = metric(y, y_pred)
    return res
# %%

# SAMPLE

print("Importando ABT...")
con = sqlalchemy.create_engine("sqlite:///../../../data/gc.db") 
df = pd.read_sql_table('tb_abt_sub', con)
print("Ok!")

## Back-test/Out of Time
### .copy() utilizado para alocar o novo objeto na memória
print("Separando entre treinamento e Backtest...")
df_oot = df[df["dtRef"].isin(['2022-01-15', '2022-01-16'])].copy()
df_train = df[~df["dtRef"].isin(['2022-01-15', '2022-01-16'])].copy()
print("Ok!")

features = df_train.columns.to_list()[2:-1]
target = 'flagSub'

print("Separando entre Treino e Teste...")
X_train, X_test, y_train, y_test = model_selection.train_test_split(df_train[features],
                                                                    df_train[target],
                                                                    random_state=42,
                                                                    test_size=0.2)
print("Ok!")
# %%

# EXPLORE

### Não se mexe mais no df_train. Mexemos apenas no X_train para ser o mais fiel possível.
cat_features = X_train.dtypes[X_train.dtypes=='object'].index.tolist()
num_features = list(set(X_train.columns) - set(cat_features))

print("Estatística de missings")
print("Missing numerico")
is_na = X_train[num_features].isna().sum()
print(is_na[is_na > 0])

missing_0 = ["avgKDA"]
missing_1 = ["vlIdade",
            "winRateAncient",
            "winRateDust2",  
            "winRateTrain",  
            "winRateInferno",
            "winRateNuke",          
            "winRateVertigo",
            "winRateMirage", 
            "winRateOverpass"]
print("Ok!")
# %%

# MODIFY
print("Construindo pipeline de ML...")
## Imputação de dados
imput_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0, variables=missing_0)
imput_1 = imputation.ArbitraryNumberImputer(arbitrary_number=-1, variables=missing_1)

## One Hot Encoding
onehot = encoding.OneHotEncoder(drop_last=True, variables=cat_features)
# %%

# MODEL
rf_clf = ensemble.RandomForestClassifier(n_estimators=200,
                                         min_samples_leaf=20,
                                         n_jobs=-1,
                                         random_state=42)

## Definir um pipeline
params = {"n_estimators":[200,250],
          "min_samples_leaf": [5,10,20] }

grid_search = model_selection.GridSearchCV(rf_clf, 
                                           params,
                                           n_jobs=1,
                                           cv=4,
                                           scoring='roc_auc',
                                           refit=True)

pipe_rf = pipeline.Pipeline(steps= [("Imput 0", imput_0),
                                    ("Imput -1", imput_1),   
                                    ("One Hot", onehot),
                                    ("Modelo", grid_search)])
print("Ok!")

print("Encontrando o melhor modelo com grid search...")
pipe_rf.fit(X_train, y_train)        
print("Ok!")

# %%

auc_train = report_model(X_train, y_train, pipe_rf, metrics.roc_auc_score)
auc_test = report_model(X_test, y_test, pipe_rf, metrics.roc_auc_score)
auc_oot = report_model(df_oot[features], df_oot[target], pipe_rf, metrics.roc_auc_score)

print("auc_train:",auc_train)
print("auc_test:",auc_test)
print("auc_oot:",auc_oot)
# %%

pipe_model = pipeline.Pipeline(steps= [("Imput 0", imput_0),
                                       ("Imput -1", imput_1),   
                                       ("One Hot", onehot),
                                       ("Modelo", grid_search.best_estimator_)])

print("Ajustando modelo para toda a base...")
pipe_model.fit(df[features], df[target])
print("Ok!")
# %%

print("Feature importance do modelo...")
features_transformed = pipe_model[:-1].transform(df[features]).columns.tolist()
features_importances = pd.DataFrame(pipe_model[-1].feature_importances_, index=features_transformed)
features_importances.sort_values(by=0, ascending=False)
print("Ok!")
# %%

series_model = pd.Series({
    "model:":pipe_model,
    "features:":features,
    "auc_train":auc_train,
    "auc_test":auc_test,
    "auc_oot":auc_oot
})
series_model.to_pickle("../../../models/modelo_subscription.pkl")
# %%
