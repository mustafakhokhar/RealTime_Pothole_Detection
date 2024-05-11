# import open cv
import cv2
import os

# load the video using path of video ( my video length is 37 sec )
video_path = "/Users/nameer/SPROJ Dropbox/Nameer Shafi/videos Karachi/video16.mp4"
video = cv2.VideoCapture(video_path)

success = True
count = 1
image_id = 1

while success:
    success , frame = video.read()
    
    if success == True:
        last_frame = frame
        
        
        # i want every 15th frame from video
        # thats why i used following line of code
        # i dont want all frames from video
        # so we can decide the outpt frames count according to us.
        
        if count%15 == 0:
            
            # specify the output path and file name
            # i used count as a file name
            # you can use any
            
            
            name = "video20_image"+str(image_id)+".jpg"
            image_id += 1
            
            # # save the image
            # cv2.imwrite(name,frame)

            output_path = '/Users/nameer/Documents/SPROJ/potholeimages_video2011'

            if not os.path.exists(output_path):
                os.makedirs(output_path)

            cv2.imwrite(os.path.join(output_path , name), frame)
        
        count += 1
    else:
        break



name2 = "video20_image"+str(image_id)+".jpg"
path2 = '/Users/nameer/Documents/SPROJ/potholeimages_video2011'
cv2.imwrite(os.path.join(path2 , name2), last_frame)

print("Total Extracted Frames :",image_id,"(after every 15th frame); Total Frames",count)  



