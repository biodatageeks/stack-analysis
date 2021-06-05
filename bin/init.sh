#!/bin/bash

echo "Creating venv for ML project"
source /opt/conda/etc/profile.d/conda.sh
PROJECT_NAME=ds-project
VENV_DIR=$HOME/work/venv/$PROJECT_NAME
conda create python=$PYTHON_MINOR -p $VENV_DIR -y 
conda activate $VENV_DIR
pip install kedro==$KEDRO_VERSION kedro-viz
pip install pandas==1.1.4 PyArrow==0.15.1

CONFIG_FILE=config.yaml
cat <<EOF >> $CONFIG_FILE
output_dir: $HOME/work/git
project_name: Datascience project
repo_name: $PROJECT_NAME
python_package: ${PROJECT_NAME//-/_}
EOF

kedro new --starter https://github.com/biodatageeks/kedro-pyspark --config $CONFIG_FILE --checkout 0.17.7
rm $CONFIG_FILE
cd $HOME/work/git/$PROJECT_NAME
kedro install
conda deactivate


echo "Creating Jupyter kernel"
KERNEL_NAME=ds-venv
ipython kernel install --name $KERNEL_NAME --display-name "Kedro (datascience)" --user
echo -e "
{
\"argv\": [
\"$VENV_DIR/bin/python3\",
\"-m\",
\"ipykernel_launcher\",
\"-f\",
\"{connection_file}\",
\"--ipython-dir\",
\"$HOME/work/git/$PROJECT_NAME/.ipython\"
],
\"env\":{
    \"KEDRO_ENV\": \"local-spark\",
    \"PYTHONPATH\": \"$PYTHONPATH:$HOME/work/git/$PROJECT_NAME/src\" 
},
\"display_name\": \"Kedro (datascience)\",
\"language\": \"python\"
}" > $HOME/.local/share/jupyter/kernels/$KERNEL_NAME/kernel.json