# Greedy-Snake-Game
2019-2020浙江大学数字逻辑设计小组大作业-基于数字系统的贪吃蛇游戏  
### 游戏规则
拨码开关控制蛇的移动并吃掉随机生成的食物，成功吃到食物后计分器分数加一，蛇的长度增加，且生成新的食物。撞墙或吃到身体，游戏结束，画面切换为初始状态，计分器清零。也可以通过拨动reset拨码开关来让其强制返回初始状态重新开始游戏。  
### 设计介绍
用GPIO中的六个拨码开关来分别控制VGA显示屏显示游戏界面，重新开始游戏，以及蛇上下左右四个方向的移动——以躲避围墙与自己的身体，并吃到在地图上各处随机生成的食物。通过不断吃到更多的食物来获得更多的分数，显示在四位七段数码管中，同时也要应对每次吃下食物蛇身增长带来的风险。 
主要分为显示和控制两个大模块，其中显示就是利用了老师给出的VGA Demo中的内容自行改造设计，将蛇头设置为绿色的矩形，蛇身其他节点设置为蓝色的矩形，食物设置为红色的矩形。背景颜色默认为白色。
而控制模块中又实现了状态机的功能——一共有四个状态：开始RESET状态，移动MOVE状态。食物生成FOOD状态与检查CHECK状态。  
* 开始RESET状态是初始化蛇的长度为2，即蛇头后连着一节蛇身；初始化蛇的位置，默认在屏幕中心偏左上方显示，以及第一个食物的位置；初始化分数，计分器清零。  
* 移动MOVE状态是根据拨码开关的开闭状态，判断想要移动的上下左右方向，更新蛇头的位置向指定方向移动一个节点长度，并将后面的身体节点分别赋值到前一个节点的位置，在连续的短暂时钟周期内不断更新，实现移动的视觉效果。  
* 食物生成FOOD状态是利用了一个随机数生成函数，得到两个随机数RANDX和RANDY，并赋值给食物的横纵坐标参数，以在蛇吃掉食物后在随机位置生成新的食物。  
* 检查CHECK状态主要检查三种特殊状态：是否撞墙、是否吃到自己的身体、以及是否吃到食物。实现的方法简单来讲都是判断蛇头的位置是否与设置的边界、食物位置、自己身体任意一个节点的位置在蛇身宽度范围内重合了，如果重合则检查到特殊状态，进行相应的进一步处理。特别注意的是，在检查CHECK状态下，如果检查到吃到食物，会让蛇的长度加一，并增加分数。  
而这四个状态转换的方式是：游戏初始界面是在开始RESET状态，检查到任意一个方向拨码开关拨动则转移到移动MOVE状态，移动MOVE状态在每个时钟周期内移动后都会自动跳转到检查CHECK状态，检查是否发生特殊事件：若吃到食物则在做出相应调整后转移到食物生成FOOD状态生成新食物，再返回移动MOVE状态；而撞墙或者吃到自己身体都会返回开始RESET状态重新新一局游戏。  
* 设计的状态图如下：  
！[img](../贪吃蛇状态图.png)
