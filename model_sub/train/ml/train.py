# %%
from asyncio.windows_utils import pipe
import pandas as pd
import sqlalchemy

import matplotlib.pyplot as plt

from sklearn import model_selection
from sklearn import ensemble
from sklearn import tree
from sklearn import linear_model


from sklearn import pipeline
from sklearn import metrics

from feature_engine import imputation
from feature_engine import encoding

import scikitplot as skplt

pd.set_option('display.max_columns', None)
# %%
# SAMPLE
con = sqlalchemy.create_engine("sqlite:///../../../data/gc.db") 
df = pd.read_sql_table('tb_abt_sub', con)

## Back-test/Out of Time
### .copy() utilizado para alocar o novo objeto na memória
df_oot = df[df["dtRef"].isin(['2022-01-15', '2022-01-16'])].copy()
df_train = df[~df["dtRef"].isin(['2022-01-15', '2022-01-16'])].copy()
features = df_train.columns.to_list()[2:-1]
target = 'flagSub'

X_train, X_test, y_train, y_test = model_selection.train_test_split(df_train[features],
                                                                    df_train[target],
                                                                    random_state=42,
                                                                    test_size=0.2)
# %%
# EXPLORE

### Não se mexe mais no df_train. Mexemos apenas no X_train para ser o mais fiel possível.
cat_features = X_train.dtypes[X_train.dtypes=='object'].index.tolist()
num_features = list(set(X_train.columns) - set(cat_features))

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

# %%
# MODIFY

## Imputação de dados
imput_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0, variables=missing_0)
imput_1 = imputation.ArbitraryNumberImputer(arbitrary_number=-1, variables=missing_1)

## One Hot Encoding
onehot = encoding.OneHotEncoder(drop_last=True, variables=cat_features)
# %%
# MODEL
rf_clf = ensemble.RandomForestClassifier(n_estimators=200, min_samples_leaf=20, n_jobs=-1, random_state=42)

## Definir um pipeline

params = {"n_estimators":[200,250],
          "min_samples_leaf": [5,10,20] }

grid_search = model_selection.GridSearchCV(rf_clf, params, n_jobs=1, cv=4, scoring='roc_auc', refit=True)

pipe_rf = pipeline.Pipeline(steps= [("Imput 0 ", imput_0),
                                       ("Imput -1", imput_1),   
                                       ("One Hot", onehot),
                                       ("Modelo", grid_search)])
# %%
pd.DataFrame(grid_search.cv_results_)
# %%

def train_test_report(model, X_train, y_train, X_test, y_test, key_metric, is_prob=True):
    model.fit(X_train, y_train)
    pred = model.predict(X_test)
    prob = model.predict_proba(X_test)
    metric_result = key_metric(y_test, prob[:,1]) if is_prob else key_metric(y_test, pred)
    return metric_result

# %%
pipe_rf.fit(X_train, y_train)        

# %%
## Assess

y_train_pred = pipe_rf.predict(X_train)
y_train_prob = pipe_rf.predict_proba(X_train)

acc_train = metrics.accuracy_score(y_train, y_train_pred)
roc_train = metrics.roc_auc_score(y_train, y_train_prob[:,1])
print("acc_train:", acc_train)
print("roc_train:", roc_train)
print("Baseline", round((1-y_train.mean())*100, 2))

# %%
y_test_pred = pipe_rf.predict(X_test)
y_test_prob = pipe_rf.predict_proba(X_test)

acc_test = metrics.accuracy_score(y_test, y_test_pred)
roc_test = metrics.roc_auc_score(y_test, y_test_prob[:,1])
print("acc_test:", acc_test)
print("roc_test:", roc_test)
print("Baseline", round((1-y_train.mean())*100, 2))

# %%
skplt.metrics.plot_roc(y_test, y_test_prob)
plt.show()
# %%
skplt.metrics.plot_ks_statistic(y_test, y_test_prob)
plt.show()
# %%
skplt.metrics.plot_lift_curve(y_test, y_test_prob)
plt.show()
# %%
skplt.metrics.plot_cumulative_gain(y_test, y_test_prob)
plt.show()
# %%
X_oot, y_oot = df_oot[features], df_oot[target]
y_prob_oot = pipe_rf.predict_proba(X_oot)
roc_oot = metrics.roc_auc_score(y_oot, y_prob_oot[:,1])
print("Roc_train:", roc_oot)

# %%
skplt.metrics.plot_lift_curve(y_oot, y_prob_oot)
plt.show()
# %%
skplt.metrics.plot_cumulative_gain(y_oot, y_prob_oot)
plt.show()
# %%
