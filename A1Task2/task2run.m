% in1 = imread('beltpotato1.jpg');
% in2 = imread('beltpotato2.jpg');
% in3 = imread('beltpotato3.jpg');
% in4 = imread('beltpotato4.jpg');
% in5 = imread('beltpotato5.jpg');
% in6 = imread('beltpotato6.jpg');
% in7 = imread('beltpotato7.jpg');
% in8 = imread('beltpotato8.jpg');
% in9 = imread('beltpotato9.jpg');
% in10 = imread('beltpotato10.jpg');
% in11 = imread('beltpotato11.jpg');
% in12 = imread('beltpotato12.jpg');
% figure, imshow([in1 in2 in3 in4 in5 in6 in7 in8 in9 in10 in11 in12])

out1 = segmentspuds('beltpotato1.jpg');
out2 = segmentspuds('beltpotato2.jpg');
out3 = segmentspuds('beltpotato3.jpg');
out4 = segmentspuds('beltpotato4.jpg');
out5 = segmentspuds('beltpotato5.jpg');
out6 = segmentspuds('beltpotato6.jpg');
out7 = segmentspuds('beltpotato7.jpg');
out8 = segmentspuds('beltpotato8.jpg');
out9 = segmentspuds('beltpotato9.jpg');
out10 = segmentspuds('beltpotato10.jpg');
out11 = segmentspuds('beltpotato11.jpg');
out12 = segmentspuds('beltpotato12.jpg');
figure, imshow([out1 out2 out3 out4 out5 out6 out7 out8 out9 out10 out11 out12]), title('All potato images segmented')