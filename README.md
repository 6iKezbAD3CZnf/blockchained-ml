# blockchained-ml
Federated Learning on Blockchain exploiting zk-SNARK.

## App
http://tk2-252-35891.vs.sakura.ne.jp:5173/

## About
個々人がプライベートなデータで学習させたAIを、サーバーを介して共有して新たなAIを構成するFederated Learningという手法が脚光を浴びている。だが、この手法はサーバーによるAIモデルの改ざんや、ユーザーによるAIモデル攻撃のリスクを孕んでいる。この解決のため、我々はサーバーの役割をブロックチェーンで置き換えた、Blockchained MLを開発した。サーバー処理をスマートコントラクトで実装することで、AIモデルの更新プロセスに偽りが無いことが誰でも検証可能になる。更に、スマートコントラクト上でゼロ知識証明の検証を行うことで、AIモデルの更新という重い処理をアウトソース化すると同時に、AIモデルへの悪意ある操作を防ぐことができる。  
今回我々が作成したのは、他人と協力して手書き数字判別AIの学習を相互検証可能な形で行えるwebサービスだ。ユーザーは、ページ上に自ら描いた数字をAIに学習させ、判定精度を学習前と比較することで、AIの学習過程を体験できる。更に、学習したAIと対応するゼロ知識証明をブロックチェーンに反映させ、全世界のユーザーに学習を引き継いでいくことができる。

## Deployed Contract
Ethereum Goerli Test Net (0xCfEb5C21Df7Ca884A703d0c70C80643c98166770)

## Resources and credits
Truffle Suite (https://trufflesuite.com/)  
Zokrates (https://github.com/Zokrates)  
TensorFlow.js (https://www.tensorflow.org/js)  
Argon - Design System (https://www.creative-tim.com/product/vue-argon-design-system)

## License
Apache License 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
