import consumer from "./consumer"

document.addEventListener('DOMContentLoaded', function() {
  const userId = document.querySelector('input[name="message[user_id]"]')?.value;
  
  
  consumer.subscriptions.create(
    {
      channel: "ChatChannel",
      user_id: userId
    },
    {
      connected() {
        console.log('Connected to chat channel for user:', userId);
      },

      disconnected() {
        console.log('Disconnected from chat channel');
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        console.log('Received message:', data);
        
        const chatMessages = document.getElementById('chat-messages');
        if (chatMessages) {
          // Remove "No messages yet" text if it exists
          const noMessages = chatMessages.querySelector('.text-muted.text-center');
          if (noMessages) {
            noMessages.remove();
          }
          
          // Append the new message HTML
          chatMessages.insertAdjacentHTML('beforeend', data.message_html);
          
          // Scroll to bottom
          chatMessages.scrollTop = chatMessages.scrollHeight;
          
          // Play notification sound (optional)
          // new Audio('/notification.mp3').play().catch(() => {});
        }
      }
    }
  );
});
